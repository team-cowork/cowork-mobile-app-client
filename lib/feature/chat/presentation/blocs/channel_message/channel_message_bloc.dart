import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/chat_socket.dart';
import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../shared/domain/profile_entity.dart';
import '../../../../../shared/domain/upload_file.dart';
import '../../../../../shared/utils/chat_author.dart';
import '../../../../../shared/utils/client_message_id.dart';
import '../../../../channel/data/repositories/channel_repository.dart';
import '../../../../channel/domain/enums/channel_type.dart';
import '../../../../profile/data/repositories/profile_repository.dart';
import '../../../data/model/chat_message_mapping.dart';
import '../../../data/model/message_socket_event.dart';
import '../../../data/model/message_type.dart';
import '../../../data/model/requests/edit_message_request.dart';
import '../../../data/model/requests/message_attachment_request.dart';
import '../../../data/model/requests/send_message_request.dart';
import '../../../data/model/responses/attachment_response.dart';
import '../../../data/model/responses/message_response.dart';
import '../../../data/repositories/chat_file_repository.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../domain/chat_message.dart';
import '../../../domain/chat_upload.dart';

part 'channel_message_event.dart';
part 'channel_message_state.dart';

/// 채널 대화 화면 상태를 관리하는 Bloc.
///
/// 최근 메시지를 읽은 뒤에는 채널 방을 소켓으로 구독해 새 메시지·수정·삭제를
/// 반영한다. 전송은 서버가 큐에 넣고 바로 돌아오므로, 보낸 메시지를 먼저 보여 주고
/// 소켓으로 저장된 메시지가 오면 `clientMessageId` 로 짝지어 바꾼다. 그 메시지가
/// [confirmTimeout] 안에 오지 않거나 소켓이 끊김 복구 없이 다시 붙으면, 최근 메시지를
/// 다시 읽어 맞춘다.
///
/// 읽음은 앱이 포그라운드일 때만 알린다. 백그라운드에서 받은 메시지는 돌아왔을 때 알린다.
///
/// [focusMessageId] 를 주면(검색 결과에서 들어올 때) 그 메시지 앞뒤를 읽어 연다. 이때는
/// 최근 메시지까지 이어져 있지 않을 수 있어([ChannelConversation.hasNewer]), 이후
/// 메시지는 아래로 내릴 때 이어 읽는다. 그동안 소켓으로 온 새 메시지는 사이가 비므로
/// 붙이지 않고, 읽음도 알리지 않는다. 그 상태에서 보내면 최근 대화로 옮긴 뒤 보낸다.
///
/// 파일은 글처럼 먼저 보여 준 뒤 올리고 보낸다. 실패하면 지우지 않고 실패로 남겨,
/// 파일을 다시 고르지 않고 다시 보내거나 지울 수 있게 한다.
class ChannelMessageBloc
    extends Bloc<ChannelMessageEvent, ChannelMessageState> {
  ChannelMessageBloc({
    required this.channelId,
    required ChannelRepository channelRepository,
    required MessageRepository messageRepository,
    required ChatFileRepository fileRepository,
    required ProfileRepository profileRepository,
    required ChatSocket socket,
    Stream<AppLifecycleState>? lifecycle,
    this.focusMessageId,
    this.confirmTimeout = const Duration(seconds: 10),
    this.markReadRetryDelay = const Duration(seconds: 3),
    DateTime Function() now = DateTime.now,
  }) : _now = now,
       _channelRepository = channelRepository,
       _messageRepository = messageRepository,
       _fileRepository = fileRepository,
       _profileRepository = profileRepository,
       _socket = socket,
       super(const ChannelMessageState.initial()) {
    on<ChannelMessageRequested>(_onLoad);
    on<ChannelMessageOlderRequested>(_onLoadOlder);
    on<ChannelMessageNewerRequested>(_onLoadNewer);
    on<ChannelMessageSent>(_onSend);
    on<ChannelMessageRetried>(_onRetry);
    on<ChannelMessageDiscarded>(_onDiscard);
    on<ChannelMessageEdited>(_onEdit);
    on<ChannelMessageDeleted>(_onDelete);
    on<_ChannelMessageSocketEventReceived>(_onSocketEvent);
    on<_ChannelMessageAuthorsResolved>(_onAuthorsResolved);
    on<_ChannelMessageConfirmTimedOut>(_onConfirmTimedOut);
    on<_ChannelMessageResynced>(_onResynced);
    on<_ChannelMessageForegroundChanged>(_onForegroundChanged);
    on<_ChannelMessageDayChanged>(_onDayChanged);
    _scheduleDayChange();

    _socketEvents = _socket.events
        .map(MessageSocketEvent.from)
        .where((event) => event != null)
        .listen((event) => add(_ChannelMessageSocketEventReceived(event!)));
    _reconnects = _socket.reconnected.listen(
      (_) => add(const _ChannelMessageResynced()),
    );
    _lifecycle = lifecycle?.listen(
      (state) => add(
        _ChannelMessageForegroundChanged(state == AppLifecycleState.resumed),
      ),
    );
    // 메시지를 읽는 사이에 온 것도 받도록 읽기 전에 들어간다.
    _socket.joinChannel(channelId);
  }

  final int channelId;

  /// 열 때 보여 줄 메시지. 없으면 최근 메시지부터 연다.
  final String? focusMessageId;

  /// 보낸 메시지가 소켓으로 저장돼 오기를 기다리는 시간.
  final Duration confirmTimeout;

  /// 읽음 요청이 실패하면 다시 보내기까지 기다리는 첫 시간. 실패할 때마다 두 배로 늘린다.
  final Duration markReadRetryDelay;

  /// 지금 시각. `오늘`·`어제` 표기를 정하고 자정을 기다리는 데 쓴다.
  final DateTime Function() _now;

  /// 자정이 지나면 `오늘`·`어제` 표기를 다시 만들려고 거는 타이머.
  Timer? _dayTimer;

  static const _maxMarkReadRetries = 3;

  /// 한 메시지에 붙일 수 있는 파일 수의 서버 상한.
  ///
  /// 서버는 넘으면 전송할 때 거절하는데, 그때는 파일을 이미 다 올린 뒤다. 올리기 전에
  /// 막아 헛된 업로드를 줄인다.
  static const maxAttachments = 10;

  final ChannelRepository _channelRepository;
  final MessageRepository _messageRepository;
  final ChatFileRepository _fileRepository;
  final ProfileRepository _profileRepository;
  final ChatSocket _socket;
  late final StreamSubscription<MessageSocketEvent?> _socketEvents;
  late final StreamSubscription<void> _reconnects;
  StreamSubscription<AppLifecycleState>? _lifecycle;

  /// 채널 머리. 불러오기에 성공하면 채워진다.
  ChannelHeader? _header;

  /// 채널을 더 볼 수 없게 된 사유. 정해지면 더는 소켓 변경·읽음을 반영하지 않는다.
  String? _closedReason;

  /// 보이는 메시지. 오래된 것부터 최신 순이고, 보낸 뒤 저장 전인 메시지는
  /// `clientMessageId` 를 id 로 들고 있다.
  final _messages = <MessageResponse>[];

  /// 작성자 id 별 표시 이름.
  final _authors = <int, ProfileEntity>{};

  /// 이름을 받아 오는 중인 작성자. 같은 사람을 여러 번 묻지 않는다.
  final _resolving = <int>{};

  /// 메시지를 읽는 동안(처음 불러오기, 이후 메시지 읽기) 온 소켓 이벤트. 목록을 받은
  /// 뒤 순서대로 반영한다. 읽는 사이 저장된 메시지를 응답과 소켓 양쪽에서 놓치지 않는다.
  final _pending = <MessageSocketEvent>[];

  int? _myId;
  bool _hasOlder = false;
  bool _loadingOlder = false;

  /// 서버에 지금 목록보다 최근 메시지가 남아 있다. [focusMessageId] 로 열었을 때만 true.
  bool _hasNewer = false;
  bool _loadingNewer = false;

  /// 화면이 맞춰 보여 줄 메시지. 최근 대화로 옮기면 지운다.
  String? _focusId;

  /// 목록을 통째로 바꿀 때(처음 불러오기, 최근 대화로 옮기기) 올린다. 이전·이후
  /// 메시지 요청은 응답을 받았을 때 번호가 바뀌었으면 결과를 버리고 상태도 건드리지
  /// 않는다. 이전 목록 기준으로 읽은 메시지가 새 목록에 붙지 않게 한다. 로딩 플래그는
  /// 번호를 올린 쪽이 정리한다.
  int _generation = 0;

  /// 진행 중인 최근 대화로 옮기기([_jumpToLatest]).
  Future<bool>? _jumping;

  /// 과거 위치를 보는 중이라 재연결 동기화를 건너뛰었다. 최근까지 내려오면 한 번 맞춘다.
  bool _resyncSkipped = false;

  /// 마지막으로 서버에 알린 읽음 위치.
  String? _lastReadId;

  /// 연달아 실패한 읽음 요청 수와, 다음에 다시 보낼 타이머.
  int _markReadFailures = 0;
  Timer? _markReadRetry;

  /// 앱이 포그라운드인지. 생명주기를 받지 않으면 늘 포그라운드로 본다.
  bool _foreground = true;

  /// 보낸 메시지(`clientMessageId`)별 저장 확인 타이머.
  final _confirmTimers = <String, Timer>{};

  /// 보내는 중이거나 보내지 못한 파일 메시지(`clientMessageId`)별 전송 상태. 저장된
  /// 메시지가 오거나 지우면 뺀다.
  final _outgoing = <String, _OutgoingFiles>{};

  Future<void> _onLoad(
    ChannelMessageRequested event,
    Emitter<ChannelMessageState> emit,
  ) async {
    emit(const ChannelMessageState.loading());
    _generation++;
    _header = null;
    _pending.clear();
    _outgoing.clear();
    _focusId = null;
    _hasNewer = false;
    _loadingNewer = false;
    _loadingOlder = false;
    _resyncSkipped = false;
    var focusMissing = false;
    try {
      final headerRequest = _channelRepository.fetchChannelHeader(channelId);
      final messagesRequest = _fetchFirstPage().then((page) {
        focusMissing = page.focusMissing;
        return page.messages;
      });
      // 내 정보는 보낼 때와 수정·삭제 표시에만 쓴다. 실패해도 대화는 보여 준다.
      final meRequest = _loadMe();
      // 채널과 메시지는 같이 보내고, 하나라도 실패하면 그 예외를 그대로 받는다.
      await Future.wait([headerRequest, messagesRequest], eagerError: true);
      final header = await headerRequest;
      final messages = await messagesRequest;
      await meRequest;
      await _fetchAuthors(messages);

      _header = header;
      // around 응답에는 기준 메시지가 들어 있어야 한다. 없으면 서버가 around 를 모르고
      // 최근 메시지를 준 것이라 최근 대화로 연다.
      final focusIndex = switch (_focusId) {
        final focus? => messages.indexWhere((message) => message.id == focus),
        null => -1,
      };
      if (_focusId != null && focusIndex == -1) {
        _focusId = null;
        focusMissing = true;
      }
      if (_focusId != null) {
        // around 는 기준 메시지 쪽(기준 포함 이전)과 이후 쪽을 반씩 읽는다. 어느 쪽이든
        // 꽉 찼으면 그 너머에 더 있다.
        _hasNewer = focusIndex >= MessageRepository.aroundHalf;
        _hasOlder =
            messages.length - focusIndex >= MessageRepository.aroundHalf;
      } else {
        _hasOlder = messages.length >= MessageRepository.pageSize;
      }
      _messages
        ..clear()
        ..addAll(messages.reversed);
    } catch (e, s) {
      Logger.e('채널 메시지 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      emit(ChannelMessageState.failure(failureMessageOf(e)));
      return;
    }

    _applyPending();
    _emit(emit, error: focusMissing ? '메시지를 찾을 수 없어 최근 대화를 보여 드려요.' : null);
    _markRead();
  }

  /// 첫 페이지. [focusMessageId] 가 있으면 그 메시지 앞뒤를 읽는다. 그 메시지가 지워져
  /// 없으면(404) 최근 메시지로 대신 연다.
  Future<({List<MessageResponse> messages, bool focusMissing})>
  _fetchFirstPage() async {
    final focus = focusMessageId;
    if (focus == null) {
      return (
        messages: await _messageRepository.fetchMessages(channelId),
        focusMissing: false,
      );
    }
    try {
      final messages = await _messageRepository.fetchMessages(
        channelId,
        around: focus,
      );
      _focusId = focus;
      return (messages: messages, focusMissing: false);
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
      return (
        messages: await _messageRepository.fetchMessages(channelId),
        focusMissing: true,
      );
    }
  }

  Future<void> _onLoadOlder(
    ChannelMessageOlderRequested event,
    Emitter<ChannelMessageState> emit,
  ) async {
    final oldest = _messages.where(_isSaved).firstOrNull;
    if (_header == null || !_hasOlder || _loadingOlder || oldest == null) {
      return;
    }
    _loadingOlder = true;
    _emit(emit);
    final generation = _generation;
    try {
      final older = await _messageRepository.fetchMessages(
        channelId,
        before: oldest.id,
      );
      await _fetchAuthors(older);
      if (generation != _generation) return;
      final known = {for (final message in _messages) message.id};
      _messages.insertAll(0, [
        for (final message in older.reversed)
          if (!known.contains(message.id)) message,
      ]);
      _hasOlder = older.length >= MessageRepository.pageSize;
      _loadingOlder = false;
      _emit(emit);
    } catch (e, s) {
      Logger.e('이전 메시지 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      if (generation != _generation) return;
      _loadingOlder = false;
      _emit(emit, error: _reasonOf('이전 메시지를 불러오지 못했어요.', e));
    }
  }

  /// 지금 목록의 가장 최근 메시지 이후를 이어 붙인다. 한 페이지가 덜 차면 최근
  /// 메시지까지 온 것이다.
  Future<void> _onLoadNewer(
    ChannelMessageNewerRequested event,
    Emitter<ChannelMessageState> emit,
  ) async {
    final newest = _messages.where(_isSaved).lastOrNull;
    if (_header == null || !_hasNewer || _loadingNewer || newest == null) {
      return;
    }
    _loadingNewer = true;
    _emit(emit);
    final generation = _generation;
    String? error;
    try {
      final newer = await _messageRepository.fetchMessages(
        channelId,
        after: newest.id,
      );
      await _fetchAuthors(newer);
      if (generation != _generation) return;
      final known = {for (final message in _messages) message.id};
      final added = [
        for (final message in newer.reversed)
          if (!known.contains(message.id)) message,
      ];
      _messages.addAll(added);
      // 꽉 찼는데 새 메시지가 하나도 없으면 서버가 after 를 무시한 것이다. 더 부르면
      // 같은 응답만 되풀이하므로 멈춘다.
      _hasNewer =
          added.isNotEmpty && newer.length >= MessageRepository.pageSize;
    } catch (e, s) {
      Logger.e('이후 메시지 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      if (generation != _generation) return;
      error = _reasonOf('이후 메시지를 불러오지 못했어요.', e);
    }
    // 이 응답을 기다리는 사이 재연결됐으면, 끊긴 동안 저장된 메시지가 응답에도 소켓에도
    // 없을 수 있다. 최근까지 왔으니 건너뛴 동기화를 지금 한다.
    if (!_hasNewer && _resyncSkipped) {
      try {
        await _syncLatest();
      } catch (e, s) {
        Logger.e('재연결 후 메시지 동기화 실패', tag: 'Chat', error: e, stackTrace: s);
      }
      if (generation != _generation) return;
    }
    _loadingNewer = false;
    _applyPending();
    _emit(emit, error: error);
    _markRead();
  }

  /// 과거 위치를 보는 중이면 최근 메시지 한 페이지로 바꾼다. 실패하면 false.
  ///
  /// 옮기는 중에 또 보내면 같은 이동을 기다린다. 따로 옮기면 먼저 끝난 쪽이
  /// [_loadingNewer] 를 풀고 최근 대화도 두 번 읽는다.
  Future<bool> _jumpToLatest() {
    if (!_hasNewer) return Future.value(true);
    return _jumping ??= _moveToLatest().whenComplete(() => _jumping = null);
  }

  /// 번호는 시작할 때와 끝날 때 올린다. 시작 전에 보낸 이후 메시지 요청이 옮기는 도중에
  /// 끝나 [_loadingNewer] 를 풀지 않게 하고, 옮기는 도중에 보낸 이전 메시지 요청이
  /// 최근 목록 위에 붙지 않게 한다.
  Future<bool> _moveToLatest() async {
    _generation++;
    _loadingNewer = true;
    try {
      await _syncLatest();
      _hasNewer = false;
      _focusId = null;
      return true;
    } catch (e, s) {
      Logger.e('최근 메시지로 이동 실패', tag: 'Chat', error: e, stackTrace: s);
      return false;
    } finally {
      _generation++;
      _loadingNewer = false;
      _loadingOlder = false;
      _applyPending();
    }
  }

  /// [ChannelMessageSent.accepted] 는 메시지를 대화에 올리면 true, 그 전에 멈추면 false
  /// 로 완료한다.
  Future<void> _onSend(
    ChannelMessageSent event,
    Emitter<ChannelMessageState> emit,
  ) async {
    void accept() {
      if (event.accepted case final accepted? when !accepted.isCompleted) {
        accepted.complete(true);
      }
    }

    try {
      final text = event.text.trim();
      if (_header == null) return;
      if (event.files.isNotEmpty) {
        await _sendFiles(text, event.files, emit, onAccepted: accept);
        return;
      }
      if (text.isEmpty) return;
      await _sendText(text, emit, onAccepted: accept);
    } finally {
      if (event.accepted case final accepted? when !accepted.isCompleted) {
        accepted.complete(false);
      }
    }
  }

  /// [text] 를 보낸다. 대화에 올리면 [onAccepted] 를 부른다.
  Future<void> _sendText(
    String text,
    Emitter<ChannelMessageState> emit, {
    required void Function() onAccepted,
  }) async {
    final myId = await _readyToSend(emit);
    if (myId == null) return;

    final clientMessageId = newClientMessageId();
    _messages.add(
      MessageResponse(
        id: clientMessageId,
        channelId: channelId,
        authorId: myId,
        content: text,
        createdAt: DateTime.now(),
        clientMessageId: clientMessageId,
      ),
    );
    onAccepted();
    _emit(emit);
    // 과거 위치에서 옮겨 왔으면 이제 최근 메시지를 보고 있다. 보내기가 실패해도 읽었다.
    _markRead();

    try {
      await _messageRepository.sendMessage(
        channelId,
        SendMessageRequest(content: text, clientMessageId: clientMessageId),
      );
      if (_isPending(clientMessageId) && !isClosed) {
        _confirmTimers[clientMessageId] = Timer(
          confirmTimeout,
          () => add(_ChannelMessageConfirmTimedOut(clientMessageId)),
        );
      }
    } catch (e, s) {
      Logger.e('메시지 전송 실패', tag: 'Chat', error: e, stackTrace: s);
      // 소켓으로 이미 저장된 메시지가 왔으면 id 가 바뀌어 있어 지워지지 않는다.
      _messages.removeWhere((message) => message.id == clientMessageId);
      _emit(emit, error: _reasonOf('메시지를 보내지 못했어요.', e));
    }
  }

  /// 보내기 전에 최근 대화로 옮기고 내 id 를 확인한다. 보낼 수 없으면 알리고 null.
  Future<int?> _readyToSend(Emitter<ChannelMessageState> emit) async {
    // 과거 위치를 보는 중이면 사이가 빈 목록 끝에 붙이지 않도록 최근 대화로 옮긴다.
    if (!await _jumpToLatest()) {
      _emit(emit, error: '최근 대화를 불러오지 못해 보낼 수 없어요. 다시 보내 주세요.');
      return null;
    }
    // 들어올 때 내 정보를 못 읽었으면 보내기 전에 한 번 더 읽는다.
    if (_myId == null) await _loadMe();
    final myId = _myId;
    if (myId == null) {
      // 입력창은 되돌아오지만 왜 안 갔는지 알 수 있게 알린다.
      _emit(emit, error: '내 정보를 불러오지 못해 보낼 수 없어요. 잠시 후 다시 시도해 주세요.');
    }
    return myId;
  }

  /// [text] 와 [files] 를 한 메시지로 보낸다. 먼저 보여 주고, 올리는 동안 진행률을
  /// 바꾼다. [text] 는 비어도 된다. 대화에 올리면 [onAccepted] 를 부른다.
  Future<void> _sendFiles(
    String text,
    List<UploadFile> files,
    Emitter<ChannelMessageState> emit, {
    required void Function() onAccepted,
  }) async {
    if (files.length > maxAttachments) {
      _emit(emit, error: '파일은 한 번에 $maxAttachments개까지 보낼 수 있어요.');
      return;
    }
    final myId = await _readyToSend(emit);
    if (myId == null) return;

    final clientMessageId = newClientMessageId();
    _outgoing[clientMessageId] = _OutgoingFiles(text, files);
    _messages.add(
      MessageResponse(
        id: clientMessageId,
        channelId: channelId,
        authorId: myId,
        content: text,
        type: MessageType.file,
        attachments: [
          for (final file in files)
            AttachmentResponse(
              name: file.name,
              size: file.size,
              mimeType: ChatFileRepository.contentTypeOf(file.name),
            ),
        ],
        createdAt: DateTime.now(),
        clientMessageId: clientMessageId,
      ),
    );
    onAccepted();
    _emit(emit);
    _markRead();
    await _deliver(clientMessageId, emit);
  }

  /// 보내지 못한 파일 메시지를 다시 보낸다.
  Future<void> _onRetry(
    ChannelMessageRetried event,
    Emitter<ChannelMessageState> emit,
  ) async {
    if (_outgoing[event.messageId]?.failed != true) return;
    await _deliver(event.messageId, emit);
  }

  /// 보내지 못한 파일 메시지를 지운다. 서버에 저장되지 않았으니 화면에서만 뺀다.
  void _onDiscard(
    ChannelMessageDiscarded event,
    Emitter<ChannelMessageState> emit,
  ) {
    if (_outgoing[event.messageId]?.failed != true) return;
    _outgoing.remove(event.messageId);
    _confirmTimers.remove(event.messageId)?.cancel();
    _messages.removeWhere((message) => message.id == event.messageId);
    _emit(emit);
  }

  /// [clientMessageId] 파일 메시지의 파일을 올리고 보낸다. 이미 올린 파일은 다시 올리지
  /// 않는다. 실패하면 메시지를 남겨 두고 실패로 표시한다.
  ///
  /// 다시 보낼 때도 같은 `clientMessageId` 를 쓴다. 서버는 올린 파일을 처음 붙인
  /// `clientMessageId` 로만 다시 붙여 주고, 메시지도 그 값으로 한 번만 저장한다. 그래서
  /// 앞선 전송이 사실은 저장됐어도 두 번 올라가지 않는다.
  Future<void> _deliver(
    String clientMessageId,
    Emitter<ChannelMessageState> emit,
  ) async {
    final outgoing = _outgoing[clientMessageId];
    if (outgoing == null || outgoing.sending) return;
    outgoing
      ..sending = true
      ..failed = false;
    _emit(emit);

    try {
      for (final (index, file) in outgoing.files.indexed) {
        if (outgoing.objectKeys[index] != null) continue;
        final confirmed = await _fileRepository.upload(
          channelId,
          file,
          onProgress: (ratio) {
            if (outgoing.report(index, ratio) && _isPending(clientMessageId)) {
              _emit(emit);
            }
          },
        );
        outgoing.objectKeys[index] = confirmed.objectKey;
      }
      await _messageRepository.sendMessage(
        channelId,
        SendMessageRequest(
          content: outgoing.content,
          clientMessageId: clientMessageId,
          type: MessageType.file,
          attachments: [
            for (final key in outgoing.objectKeys)
              MessageAttachmentRequest(objectKey: key!),
          ],
        ),
      );
      outgoing.sending = false;
      if (_isPending(clientMessageId) && !isClosed) {
        _confirmTimers[clientMessageId] = Timer(
          confirmTimeout,
          () => add(_ChannelMessageConfirmTimedOut(clientMessageId)),
        );
      }
    } catch (e, s) {
      Logger.e('파일 전송 실패', tag: 'Chat', error: e, stackTrace: s);
      outgoing
        ..sending = false
        ..failed = true;
      // 그사이 저장된 메시지가 소켓으로 왔거나 지웠으면 알릴 게 없다.
      if (!_isPending(clientMessageId)) return;
      _emit(emit, error: _reasonOf('파일을 보내지 못했어요.', e));
    }
  }

  /// 내 메시지를 고친다. 서버가 받아들인 뒤에 바꿔 보인다.
  Future<void> _onEdit(
    ChannelMessageEdited event,
    Emitter<ChannelMessageState> emit,
  ) async {
    final text = event.text.trim();
    final index = _messages.indexWhere((m) => m.id == event.messageId);
    if (text.isEmpty || index == -1 || _messages[index].content == text) return;
    try {
      await _messageRepository.editMessage(
        channelId,
        event.messageId,
        EditMessageRequest(content: text),
      );
    } catch (e, s) {
      Logger.e('메시지 수정 실패', tag: 'Chat', error: e, stackTrace: s);
      _emit(emit, error: _reasonOf('메시지를 고치지 못했어요.', e));
      return;
    }
    if (_apply(MessageEdited(messageId: event.messageId, content: text))) {
      _emit(emit);
    }
  }

  /// 내 메시지를 지운다. 서버가 받아들인 뒤에 뺀다.
  Future<void> _onDelete(
    ChannelMessageDeleted event,
    Emitter<ChannelMessageState> emit,
  ) async {
    try {
      await _messageRepository.deleteMessage(channelId, event.messageId);
    } catch (e, s) {
      Logger.e('메시지 삭제 실패', tag: 'Chat', error: e, stackTrace: s);
      _emit(emit, error: _reasonOf('메시지를 지우지 못했어요.', e));
      return;
    }
    if (_apply(MessageDeleted(event.messageId))) _emit(emit);
  }

  void _onSocketEvent(
    _ChannelMessageSocketEventReceived event,
    Emitter<ChannelMessageState> emit,
  ) {
    if (_closedReason != null) return;
    if (_header == null || _loadingNewer) {
      _pending.add(event.event);
      return;
    }
    if (_apply(event.event)) {
      _emit(emit);
      _markRead();
    }
  }

  /// 보낸 메시지가 소켓으로 오지 않았다. 최근 메시지를 다시 읽어 보고, 그래도 없으면
  /// 저장되지 않은 것으로 보고 뺀다.
  Future<void> _onConfirmTimedOut(
    _ChannelMessageConfirmTimedOut event,
    Emitter<ChannelMessageState> emit,
  ) async {
    _confirmTimers.remove(event.clientMessageId);
    if (!_isPending(event.clientMessageId)) return;
    try {
      await _syncLatest();
    } catch (e, s) {
      Logger.e('보낸 메시지 확인 실패', tag: 'Chat', error: e, stackTrace: s);
    }
    if (!_isPending(event.clientMessageId)) {
      _emit(emit);
      _markRead();
      return;
    }
    // 파일 메시지는 다시 고르지 않아도 되게 남겨 두고 실패로 표시한다. 다시 보내도
    // 같은 `clientMessageId` 라 서버에 두 번 저장되지 않는다.
    if (_outgoing[event.clientMessageId] case final outgoing?) {
      outgoing.failed = true;
      _emit(emit, error: '파일이 전송되지 않았어요. 다시 보내 주세요.');
      return;
    }
    _messages.removeWhere((message) => message.id == event.clientMessageId);
    _emit(emit, error: '메시지가 전송되지 않았어요. 다시 보내 주세요.');
  }

  /// 소켓이 끊김 복구 없이 다시 붙었다. 끊긴 동안의 변경을 다시 읽어 맞춘다.
  Future<void> _onResynced(
    _ChannelMessageResynced event,
    Emitter<ChannelMessageState> emit,
  ) async {
    if (_header == null) return;
    // 과거 위치를 보는 중이면 최근 메시지로 바꾸지 않는다. 아래로 내리면 이후 메시지를
    // 새로 읽고, 최근까지 오면 그때 맞춘다([_onLoadNewer]).
    if (_hasNewer) {
      _resyncSkipped = true;
      return;
    }
    try {
      await _syncLatest();
    } catch (e, s) {
      Logger.e('재연결 후 메시지 동기화 실패', tag: 'Chat', error: e, stackTrace: s);
      return;
    }
    _emit(emit);
    _markRead();
  }

  void _onForegroundChanged(
    _ChannelMessageForegroundChanged event,
    Emitter<ChannelMessageState> emit,
  ) {
    _foreground = event.foreground;
    if (_foreground && _header != null) _markRead();
  }

  void _onAuthorsResolved(
    _ChannelMessageAuthorsResolved event,
    Emitter<ChannelMessageState> emit,
  ) {
    for (final author in event.authors) {
      _authors[author.id] = author;
    }
    if (_header != null) _emit(emit);
  }

  /// 읽는 동안 쌓아 둔 소켓 이벤트를 순서대로 반영한다.
  void _applyPending() {
    for (final change in _pending) {
      _apply(change);
    }
    _pending.clear();
  }

  /// 소켓 이벤트를 [_messages] 에 반영한다. 바뀐 게 있으면 true.
  bool _apply(MessageSocketEvent event) {
    switch (event) {
      case MessageReceived(:final message):
        if (message.channelId != channelId || message.parentMessageId != null) {
          return false;
        }
        final index = _messages.indexWhere(
          (other) =>
              other.id == message.id ||
              (message.clientMessageId != null &&
                  other.id == message.clientMessageId),
        );
        if (index == -1) {
          // 과거 위치를 보는 중이면 사이가 비어 붙이지 않는다. 이후 메시지를 읽을 때 온다.
          if (_hasNewer) return false;
          _messages.add(message);
        } else if (_isSaved(_messages[index])) {
          _messages[index] = message;
        } else {
          // 보낸 메시지가 저장됐다. 보낼 때 맨 끝에 넣어 뒀으므로, 그사이 소켓으로 온
          // 다른 사람의 메시지와 서버 순서가 다르면 자리를 옮긴다. 서버는 `createdAt`
          // 이 아니라 id 순서로 목록을 주므로 id 로 비교하고, 아직 저장 확인이 안 된
          // 다른 보낸 메시지는 계속 맨 뒤에 둔다.
          _messages.removeAt(index);
          final unsaved = [
            for (final other in _messages)
              if (!_isSaved(other)) other,
          ];
          _messages.removeWhere((other) => !_isSaved(other));
          final after = _messages.lastIndexWhere(
            (other) => other.id.compareTo(message.id) < 0,
          );
          _messages
            ..insert(after + 1, message)
            ..addAll(unsaved);
        }
        _confirmTimers.remove(message.clientMessageId)?.cancel();
        _outgoing.remove(message.clientMessageId);
        if (message.personId case final id? when !_authors.containsKey(id)) {
          _resolveAuthorsLater([id]);
        }
        return true;
      case MessageEdited(:final messageId, :final content):
        final index = _messages.indexWhere((other) => other.id == messageId);
        if (index == -1) return false;
        _messages[index] = _messages[index].copyWith(content: content);
        return true;
      case MessageDeleted(:final messageId):
        final before = _messages.length;
        _messages.removeWhere((other) => other.id == messageId);
        return _messages.length != before;
      case ChannelAccessLost(:final channelId, :final teamId, :final reason):
        final mine =
            channelId == this.channelId ||
            (teamId != null && teamId == _header?.teamId);
        if (!mine || _closedReason != null) return false;
        _closedReason = switch (reason) {
          ChannelAccessLostReason.deleted => '채널이 삭제됐어요.',
          ChannelAccessLostReason.revoked => '이 채널에 더 이상 접근할 수 없어요.',
          ChannelAccessLostReason.leftTeam => '팀에서 빠져서 이 채널을 볼 수 없어요.',
        };
        return true;
    }
  }

  /// 최근 메시지 한 페이지를 다시 읽어 [_messages] 와 맞춘다.
  ///
  /// 읽은 범위 안의 메시지는 서버 것으로 바꾸고(그 사이 지워진 것은 빠진다), 그보다
  /// 오래된 메시지는 이어지는 경우에만 남긴다. 읽는 사이 소켓으로 온 더 최근 메시지와
  /// 저장 확인이 안 된 보낸 메시지는 그 뒤에 둔다.
  Future<void> _syncLatest() async {
    final page = await _messageRepository.fetchMessages(channelId);
    await _fetchAuthors(page);
    _resyncSkipped = false;

    final fetchedIds = {for (final message in page) message.id};
    final confirmed = {
      for (final message in page)
        if (message.clientMessageId != null) message.clientMessageId!,
    };
    final full = page.length >= MessageRepository.pageSize;
    final oldestFetched = page.lastOrNull;
    // 끊긴 동안 한 페이지보다 많이 쌓였으면 남은 오래된 메시지와 이어지지 않는다.
    final continuous = _messages.any(
      (message) => _isSaved(message) && fetchedIds.contains(message.id),
    );
    final older = full && continuous && oldestFetched != null
        ? [
            for (final message in _messages)
              if (_isSaved(message) &&
                  !fetchedIds.contains(message.id) &&
                  message.createdAt.isBefore(oldestFetched.createdAt))
                message,
          ]
        : <MessageResponse>[];
    // 다시 읽는 사이 소켓으로 먼저 들어온 더 최근 메시지는 남긴다.
    final newestFetched = page.firstOrNull;
    final newer = newestFetched == null
        ? <MessageResponse>[]
        : [
            for (final message in _messages)
              if (_isSaved(message) &&
                  !fetchedIds.contains(message.id) &&
                  message.createdAt.isAfter(newestFetched.createdAt))
                message,
          ];
    final pending = [
      for (final message in _messages)
        if (!_isSaved(message) && !confirmed.contains(message.id)) message,
    ];
    for (final id in confirmed) {
      _confirmTimers.remove(id)?.cancel();
      _outgoing.remove(id);
    }

    _hasOlder = full && (older.isEmpty || _hasOlder);
    _messages
      ..clear()
      ..addAll(older)
      ..addAll(page.reversed)
      ..addAll(newer)
      ..addAll(pending);
  }

  /// 내 id 와 이름을 읽어 [_myId]·[_authors] 에 넣는다. 실패하면 로그만 남긴다.
  Future<void> _loadMe() async {
    try {
      final me = await _profileRepository.fetchMe();
      final myId = me.id;
      if (myId == null) return;
      _myId = myId;
      _authors[myId] = chatAuthorOf(myId, me.name ?? '');
    } catch (e, s) {
      Logger.e('내 정보 조회 실패', tag: 'Chat', error: e, stackTrace: s);
    }
  }

  /// [messages] 작성자 중 이름을 모르는 사람을 한꺼번에 받아 [_authors] 에 넣는다.
  Future<void> _fetchAuthors(Iterable<MessageResponse> messages) async {
    final unknown = {
      for (final message in messages)
        if (message.personId case final id? when !_authors.containsKey(id)) id,
    };
    if (unknown.isEmpty) return;
    for (final user in await _profileRepository.fetchDisplayNames(unknown)) {
      _authors[user.id] = chatAuthorOf(user.id, user.displayName);
    }
  }

  /// 소켓으로 온 메시지의 작성자 이름을 기다리지 않고 받아 온다. 그동안은
  /// [unknownChatAuthor] 로 보이고, 받아 오면 [_ChannelMessageAuthorsResolved] 로 바꾼다.
  void _resolveAuthorsLater(Iterable<int> authorIds) {
    final ids = authorIds.where(_resolving.add).toList();
    if (ids.isEmpty) return;
    _profileRepository
        .fetchDisplayNames(ids)
        .then((users) {
          if (isClosed) return;
          add(
            _ChannelMessageAuthorsResolved([
              for (final user in users) chatAuthorOf(user.id, user.displayName),
            ]),
          );
        })
        .catchError((Object e, StackTrace s) {
          Logger.e('작성자 이름 조회 실패', tag: 'Chat', error: e, stackTrace: s);
        })
        .whenComplete(() => _resolving.removeAll(ids));
  }

  /// 채널 화면이 이 채널의 메시지를 보여 주는지. 채널을 아직 못 읽었으면 false.
  bool get _showsMessages => switch (_header?.type) {
    ChannelType.chat || ChannelType.webhook => true,
    _ => false,
  };

  /// 가장 최근에 저장된 메시지까지 읽었다고 알린다. 실패해도 화면엔 영향이 없다.
  void _markRead() {
    // 앱이 메시지를 보여 주지 않는 종류(안내만 보임)는 사용자가 읽지 않았으니 알리지 않는다.
    if (!_showsMessages) return;
    // 과거 위치를 보는 중이면 그보다 최근 메시지를 안 읽었으니 알리지 않는다.
    if (!_foreground || _closedReason != null || _hasNewer) return;
    final latest = _messages.reversed.where(_isSaved).firstOrNull;
    if (latest == null || latest.id == _lastReadId) return;
    _lastReadId = latest.id;
    _messageRepository
        .markRead(channelId, latest.id)
        .then((_) => _markReadFailures = 0)
        .catchError((Object e, StackTrace s) {
          Logger.e('읽음 처리 실패', tag: 'Chat', error: e, stackTrace: s);
          // 같은 위치를 다시 보낼 수 있게 풀고, 다음 새 메시지를 기다리지 않고 다시 보낸다.
          if (_lastReadId == latest.id) _lastReadId = null;
          _scheduleMarkReadRetry();
          return 0;
        });
  }

  /// 읽음 요청이 실패했을 때 간격을 두 배씩 늘려 세 번까지만 다시 보낸다.
  void _scheduleMarkReadRetry() {
    if (isClosed || _markReadFailures >= _maxMarkReadRetries) return;
    _markReadRetry?.cancel();
    _markReadRetry = Timer(markReadRetryDelay * (1 << _markReadFailures), () {
      if (!isClosed) _markRead();
    });
    _markReadFailures++;
  }

  /// 다음 자정에 표기를 다시 만든다.
  void _scheduleDayChange() {
    final now = _now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _dayTimer?.cancel();
    _dayTimer = Timer(midnight.difference(now), () {
      if (!isClosed) add(const _ChannelMessageDayChanged());
    });
  }

  void _onDayChanged(
    _ChannelMessageDayChanged event,
    Emitter<ChannelMessageState> emit,
  ) {
    _emit(emit);
    _scheduleDayChange();
  }

  void _emit(Emitter<ChannelMessageState> emit, {String? error}) {
    final header = _header;
    if (header == null) return;
    final conversation = _conversationOf(header);
    // 같은 사유로 연달아 실패하면 상태가 같아 무시된다. 사유 없는 상태를 먼저 내서
    // 화면이 매번 알리게 한다.
    if (error != null) emit(ChannelMessageState.success(conversation));
    emit(
      ChannelMessageState.success(
        error == null ? conversation : conversation.withError(error),
      ),
    );
  }

  ChannelConversation _conversationOf(ChannelHeader header) {
    final now = _now();
    return ChannelConversation(
      name: header.name,
      description: header.description,
      type: header.type,
      messages: [
        for (final message in _messages)
          chatMessageOf(
            message,
            _authorOf(message),
            now: now,
            editable: _isEditable(message),
            upload: _outgoing[message.id]?.state,
          ),
      ],
      hasOlder: _hasOlder,
      loadingOlder: _loadingOlder,
      hasNewer: _hasNewer,
      loadingNewer: _loadingNewer,
      focusMessageId: _focusId,
      closedReason: _closedReason,
    );
  }

  ProfileEntity _authorOf(MessageResponse message) =>
      messageAuthorOf(message, _authors);

  bool _isEditable(MessageResponse message) =>
      message.personId != null &&
      _isSaved(message) &&
      message.personId == _myId;

  bool _isPending(String clientMessageId) =>
      _messages.any((message) => message.id == clientMessageId);

  @override
  Future<void> close() async {
    _socket.leaveChannel(channelId);
    for (final timer in _confirmTimers.values) {
      timer.cancel();
    }
    _confirmTimers.clear();
    _markReadRetry?.cancel();
    _dayTimer?.cancel();
    await _socketEvents.cancel();
    await _reconnects.cancel();
    await _lifecycle?.cancel();
    return super.close();
  }

  /// 서버에 저장된 메시지. 보낸 뒤 저장 전인 메시지는 id 가 `clientMessageId` 다.
  static bool _isSaved(MessageResponse message) =>
      message.id != message.clientMessageId;

  static String _reasonOf(String fallback, Object error) =>
      failureMessageOf(error) ?? fallback;
}

/// 보내는 중이거나 보내지 못한 파일 메시지 하나의 전송 상태.
class _OutgoingFiles {
  _OutgoingFiles(this.content, this.files)
    : objectKeys = List.filled(files.length, null),
      _total = files.fold(0, (sum, file) => sum + file.size);

  /// 파일과 같이 보낼 글. 비어도 된다.
  final String content;

  final List<UploadFile> files;

  /// 올린 파일의 확정 키. 다시 보낼 때 이미 올린 파일은 건너뛴다.
  final List<String?> objectKeys;

  final int _total;
  double _progress = 0;

  /// 지금 올리거나 보내는 중이다. 같은 메시지를 겹쳐 보내지 않는다.
  bool sending = false;

  /// 보내지 못했다.
  bool failed = false;

  ChatUpload get state => ChatUpload(progress: _progress, failed: failed);

  /// [index] 번째 파일을 [ratio] 만큼 올렸다. 화면에 보일 퍼센트가 바뀌었으면 true.
  ///
  /// 올리는 동안 아주 자주 불리므로, 퍼센트가 바뀔 때만 화면을 다시 그리게 한다.
  bool report(int index, double ratio) {
    var sent = 0.0;
    for (final (i, file) in files.indexed) {
      if (i == index) {
        sent += file.size * ratio.clamp(0, 1);
      } else if (objectKeys[i] != null) {
        sent += file.size;
      }
    }
    final next = _total == 0 ? 1.0 : sent / _total;
    final changed = (next * 100).floor() != (_progress * 100).floor();
    _progress = next;
    return changed;
  }
}
