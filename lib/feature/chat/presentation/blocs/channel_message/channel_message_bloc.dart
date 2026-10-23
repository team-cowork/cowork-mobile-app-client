import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../network/chat_socket.dart';
import '../../../../../network/http_error_message.dart';
import '../../../../profile/data/repositories/profile_repository.dart';
import '../../../../profile/domain/profile_entity.dart';
import '../../../data/model/chat_message_mapping.dart';
import '../../../data/model/message_socket_event.dart';
import '../../../data/model/requests/edit_message_request.dart';
import '../../../data/model/requests/send_message_request.dart';
import '../../../data/model/responses/message_response.dart';
import '../../../data/repositories/channel_repository.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../domain/chat_message.dart';

part 'channel_message_event.dart';
part 'channel_message_state.dart';

/// 채널 대화 화면 상태를 관리하는 Bloc.
///
/// 최근 메시지를 읽은 뒤에는 채널 방을 소켓으로 구독해 새 메시지·수정·삭제를
/// 반영한다. 전송은 서버가 큐에 넣고 바로 돌아오므로, 보낸 메시지를 먼저 보여 주고
/// 소켓으로 저장된 메시지가 오면 `clientMessageId` 로 짝지어 바꾼다. 그 메시지가
/// [confirmTimeout] 안에 오지 않거나 소켓이 끊김 복구 없이 다시 붙으면, 최근 메시지를
/// 다시 읽어 맞춘다.
class ChannelMessageBloc
    extends Bloc<ChannelMessageEvent, ChannelMessageState> {
  ChannelMessageBloc({
    required this.channelId,
    required ChannelRepository channelRepository,
    required MessageRepository messageRepository,
    required ProfileRepository profileRepository,
    required ChatSocket socket,
    this.confirmTimeout = const Duration(seconds: 10),
  }) : _channelRepository = channelRepository,
       _messageRepository = messageRepository,
       _profileRepository = profileRepository,
       _socket = socket,
       super(const ChannelMessageState.initial()) {
    on<ChannelMessageRequested>(_onLoad);
    on<ChannelMessageOlderRequested>(_onLoadOlder);
    on<ChannelMessageSent>(_onSend);
    on<ChannelMessageEdited>(_onEdit);
    on<ChannelMessageDeleted>(_onDelete);
    on<_ChannelMessageSocketEventReceived>(_onSocketEvent);
    on<_ChannelMessageAuthorsResolved>(_onAuthorsResolved);
    on<_ChannelMessageConfirmTimedOut>(_onConfirmTimedOut);
    on<_ChannelMessageResynced>(_onResynced);

    _socketEvents = _socket.events
        .map(MessageSocketEvent.from)
        .where((event) => event != null)
        .listen((event) => add(_ChannelMessageSocketEventReceived(event!)));
    _reconnects = _socket.reconnected.listen(
      (_) => add(const _ChannelMessageResynced()),
    );
    // 메시지를 읽는 사이에 온 것도 받도록 읽기 전에 들어간다.
    _socket.joinChannel(channelId);
  }

  final int channelId;

  /// 보낸 메시지가 소켓으로 저장돼 오기를 기다리는 시간.
  final Duration confirmTimeout;

  final ChannelRepository _channelRepository;
  final MessageRepository _messageRepository;
  final ProfileRepository _profileRepository;
  final ChatSocket _socket;
  late final StreamSubscription<MessageSocketEvent?> _socketEvents;
  late final StreamSubscription<void> _reconnects;

  /// 채널 머리. 불러오기에 성공하면 채워진다.
  ({String name, String description})? _header;

  /// 보이는 메시지. 오래된 것부터 최신 순이고, 보낸 뒤 저장 전인 메시지는
  /// `clientMessageId` 를 id 로 들고 있다.
  final _messages = <MessageResponse>[];

  /// 작성자 id 별 표시 이름.
  final _authors = <int, ProfileEntity>{};

  /// 이름을 받아 오는 중인 작성자. 같은 사람을 여러 번 묻지 않는다.
  final _resolving = <int>{};

  /// 메시지를 읽는 동안 온 소켓 이벤트. 목록을 받은 뒤 순서대로 반영한다.
  final _pending = <MessageSocketEvent>[];

  int? _myId;
  bool _hasOlder = false;
  bool _loadingOlder = false;

  /// 보낸 메시지(`clientMessageId`)별 저장 확인 타이머.
  final _confirmTimers = <String, Timer>{};

  Future<void> _onLoad(
    ChannelMessageRequested event,
    Emitter<ChannelMessageState> emit,
  ) async {
    emit(const ChannelMessageState.loading());
    _header = null;
    _pending.clear();
    try {
      final headerRequest = _channelRepository.fetchChannelHeader(channelId);
      final messagesRequest = _messageRepository.fetchMessages(channelId);
      final meRequest = _profileRepository.fetchMe();
      // 셋을 같이 보내고, 하나라도 실패하면 그 예외를 그대로 받는다.
      await Future.wait([
        headerRequest,
        messagesRequest,
        meRequest,
      ], eagerError: true);
      final header = await headerRequest;
      final messages = await messagesRequest;
      final me = await meRequest;
      final myId = me.id;
      if (myId != null) {
        _myId = myId;
        _authors[myId] = chatAuthorOf(myId, me.name ?? '');
      }
      await _fetchAuthors(messages);

      _header = header;
      _hasOlder = messages.length >= MessageRepository.pageSize;
      _messages
        ..clear()
        ..addAll(messages.reversed);
    } catch (e, s) {
      Logger.e('채널 메시지 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      emit(
        ChannelMessageState.failure(
          e is DioException ? dioErrorMessage(e) : null,
        ),
      );
      return;
    }

    for (final change in _pending) {
      _apply(change);
    }
    _pending.clear();
    _emit(emit);
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
    try {
      final older = await _messageRepository.fetchMessages(
        channelId,
        before: oldest.id,
      );
      await _fetchAuthors(older);
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
      _loadingOlder = false;
      _emit(emit, error: _reasonOf('이전 메시지를 불러오지 못했어요.', e));
    }
  }

  Future<void> _onSend(
    ChannelMessageSent event,
    Emitter<ChannelMessageState> emit,
  ) async {
    final text = event.text.trim();
    if (_header == null || text.isEmpty) return;
    final myId = _myId;
    if (myId == null) {
      // 입력창은 이미 비워졌으니 조용히 버리지 않고 알린다.
      _emit(emit, error: '내 정보를 불러오지 못해 보낼 수 없어요. 다시 들어와 주세요.');
      return;
    }

    final clientMessageId = _newClientMessageId();
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
    _emit(emit);

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
    if (_header == null) {
      _pending.add(event.event);
      return;
    }
    if (_apply(event.event)) _emit(emit);
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
    try {
      await _syncLatest();
    } catch (e, s) {
      Logger.e('재연결 후 메시지 동기화 실패', tag: 'Chat', error: e, stackTrace: s);
      return;
    }
    _emit(emit);
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
          _messages.add(message);
        } else {
          _messages[index] = message;
        }
        _confirmTimers.remove(message.clientMessageId)?.cancel();
        if (!message.isSystem && !_authors.containsKey(message.authorId)) {
          _resolveAuthorsLater([message.authorId]);
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
    }

    _hasOlder = full && (older.isEmpty || _hasOlder);
    _messages
      ..clear()
      ..addAll(older)
      ..addAll(page.reversed)
      ..addAll(newer)
      ..addAll(pending);
  }

  /// [messages] 작성자 중 이름을 모르는 사람을 한꺼번에 받아 [_authors] 에 넣는다.
  Future<void> _fetchAuthors(Iterable<MessageResponse> messages) async {
    final unknown = {
      for (final message in messages)
        if (!message.isSystem && !_authors.containsKey(message.authorId))
          message.authorId,
    };
    if (unknown.isEmpty) return;
    for (final user in await _messageRepository.fetchDisplayNames(unknown)) {
      _authors[user.id] = chatAuthorOf(user.id, user.name);
    }
  }

  /// 소켓으로 온 메시지의 작성자 이름을 기다리지 않고 받아 온다. 그동안은
  /// [unknownChatAuthor] 로 보이고, 받아 오면 [_ChannelMessageAuthorsResolved] 로 바꾼다.
  void _resolveAuthorsLater(Iterable<int> authorIds) {
    final ids = authorIds.where(_resolving.add).toList();
    if (ids.isEmpty) return;
    _messageRepository
        .fetchDisplayNames(ids)
        .then((users) {
          if (isClosed) return;
          add(
            _ChannelMessageAuthorsResolved([
              for (final user in users) chatAuthorOf(user.id, user.name),
            ]),
          );
        })
        .catchError((Object e, StackTrace s) {
          Logger.e('작성자 이름 조회 실패', tag: 'Chat', error: e, stackTrace: s);
        })
        .whenComplete(() => _resolving.removeAll(ids));
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

  ChannelConversation _conversationOf(
    ({String name, String description}) header,
  ) {
    final now = DateTime.now();
    return ChannelConversation(
      name: header.name,
      description: header.description,
      messages: [
        for (final message in _messages)
          chatMessageOf(
            message,
            _authorOf(message),
            now: now,
            editable: _isEditable(message),
          ),
      ],
      hasOlder: _hasOlder,
      loadingOlder: _loadingOlder,
    );
  }

  ProfileEntity _authorOf(MessageResponse message) => message.isSystem
      ? systemChatAuthor(message.authorId)
      : _authors[message.authorId] ?? unknownChatAuthor(message.authorId);

  bool _isEditable(MessageResponse message) =>
      !message.isSystem && _isSaved(message) && message.authorId == _myId;

  bool _isPending(String clientMessageId) =>
      _messages.any((message) => message.id == clientMessageId);

  @override
  Future<void> close() async {
    _socket.leaveChannel(channelId);
    for (final timer in _confirmTimers.values) {
      timer.cancel();
    }
    _confirmTimers.clear();
    await _socketEvents.cancel();
    await _reconnects.cancel();
    return super.close();
  }

  /// 서버에 저장된 메시지. 보낸 뒤 저장 전인 메시지는 id 가 `clientMessageId` 다.
  static bool _isSaved(MessageResponse message) =>
      message.id != message.clientMessageId;

  static String _reasonOf(String fallback, Object error) =>
      error is DioException ? dioErrorMessage(error) : fallback;

  /// 멱등성 키로 쓸 UUID v4.
  static String _newClientMessageId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
