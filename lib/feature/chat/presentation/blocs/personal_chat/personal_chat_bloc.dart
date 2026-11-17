import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/chat_socket.dart';
import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../shared/domain/profile_entity.dart';
import '../../../../profile/data/profile_store.dart';
import '../../../data/model/chat_message_mapping.dart';
import '../../../data/model/dm_preview_mapping.dart';
import '../../../data/model/responses/dm_conversation_response.dart';
import '../../../data/repositories/dm_repository.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../domain/direct_message_preview.dart';

part 'personal_chat_event.dart';
part 'personal_chat_state.dart';

/// DM 목록 화면 상태를 관리하는 Bloc.
///
/// 목록에 있는 대화의 채널 방을 소켓으로 구독해, 새 메시지가 오면 미리보기·정렬·읽지
/// 않은 수를 다시 읽는다. 서버는 메시지를 채널 방에만 보내므로 열어 두지 않은 대화의
/// 메시지를 받으려면 방에 들어가 있어야 한다. 소켓이 끊김 복구 없이 다시 붙어도 다시
/// 읽는다. 목록에 없던 새 대화는 소켓 이벤트가 없어 화면에 들어올 때와 대화 화면에서
/// 돌아올 때 알게 된다.
class PersonalChatBloc extends Bloc<PersonalChatEvent, PersonalChatState> {
  PersonalChatBloc({
    required DmRepository dmRepository,
    required MessageRepository messageRepository,
    required ChatSocket socket,
    this.retryDelay = const Duration(seconds: 3),
  }) : _dmRepository = dmRepository,
       _messageRepository = messageRepository,
       _socket = socket,
       super(const PersonalChatState.initial()) {
    on<PersonalChatRequested>(_onLoad);
    on<PersonalChatRefreshed>(_onRefresh);
    on<PersonalChatHidden>(_onHide);
    _socketEvents = _socket.events.listen(_onSocketEvent);
    _reconnects = _socket.reconnected.listen(
      (_) => add(const PersonalChatEvent.refreshed()),
    );
  }

  final DmRepository _dmRepository;
  final MessageRepository _messageRepository;
  final ChatSocket _socket;

  /// 조용한 갱신이 실패하면 다시 읽기까지 기다리는 첫 시간. 실패할 때마다 두 배로 늘린다.
  final Duration retryDelay;

  static const _maxRefreshRetries = 3;
  late final StreamSubscription<SocketEvent> _socketEvents;
  late final StreamSubscription<void> _reconnects;

  /// 상대 id 별 표시 이름. 같은 사람을 다시 읽을 때마다 묻지 않는다.
  final _names = <int, String>{};

  /// 지금 보이는 대화. 숨기기 실패 때 그대로 되돌리는 데 쓴다.
  List<DirectMessagePreview> _conversations = const [];

  /// 구독 중인 DM 채널 방.
  final _rooms = <int>{};

  /// 숨기는 요청이 오가는 대화. 그사이 시작된 목록 읽기가 되살리지 않게 뺀다.
  final _hiding = <int>{};

  /// 연달아 실패한 갱신 횟수와, 그다음 다시 읽을 타이머.
  int _refreshFailures = 0;
  Timer? _retryTimer;

  bool _refreshing = false;
  bool _refreshQueued = false;

  Future<void> _onLoad(
    PersonalChatRequested event,
    Emitter<PersonalChatState> emit,
  ) async {
    emit(const PersonalChatState.loading());
    try {
      _conversations = await _fetch();
    } catch (e, s) {
      Logger.e('DM 목록 조회 실패', tag: 'PersonalChat', error: e, stackTrace: s);
      emit(PersonalChatState.failure(failureMessageOf(e)));
      return;
    }
    _emit(emit);
  }

  /// 이미 목록이 있으면 실패해도 그대로 둔다. 새 메시지마다 오는 조용한 갱신이라 화면을
  /// 오류로 바꾸지 않는다. 읽는 동안 또 요청이 오면 끝난 뒤 한 번 더 읽는다.
  Future<void> _onRefresh(
    PersonalChatRefreshed event,
    Emitter<PersonalChatState> emit,
  ) async {
    if (state is! AsyncSuccess<PersonalChatData>) return;
    if (_refreshing) {
      _refreshQueued = true;
      return;
    }
    _refreshing = true;
    try {
      do {
        _refreshQueued = false;
        try {
          _conversations = await _fetch();
        } catch (e, s) {
          Logger.e('DM 목록 갱신 실패', tag: 'PersonalChat', error: e, stackTrace: s);
          _scheduleRetry();
          continue;
        }
        if (isClosed) return;
        _refreshFailures = 0;
        _retryTimer?.cancel();
        _emit(emit);
      } while (_refreshQueued && !isClosed);
    } finally {
      _refreshing = false;
    }
  }

  /// 갱신이 실패하면 새 메시지나 재연결을 기다리지 않고 스스로 다시 읽는다. 조용한 갱신이라
  /// 실패를 화면에 알리지 않으므로, 이게 없으면 다음 이벤트가 올 때까지 옛 목록이 남는다.
  /// 실패가 이어지면 간격을 두 배씩 늘려 세 번까지만 다시 시도한다.
  void _scheduleRetry() {
    if (isClosed || _refreshFailures >= _maxRefreshRetries) return;
    _retryTimer?.cancel();
    _retryTimer = Timer(retryDelay * (1 << _refreshFailures), () {
      if (!isClosed) add(const PersonalChatEvent.refreshed());
    });
    _refreshFailures++;
  }

  /// 목록에서 먼저 빼고 서버에 숨긴다. 실패하면 그 대화를 되돌리고 사유를 알린다.
  Future<void> _onHide(
    PersonalChatHidden event,
    Emitter<PersonalChatState> emit,
  ) async {
    final index = _conversations.indexWhere(
      (conversation) => conversation.channelId == event.channelId,
    );
    if (index < 0) return;
    final hidden = _conversations[index];

    _hiding.add(event.channelId);
    _conversations = [..._conversations]..removeAt(index);
    _emit(emit);
    try {
      await _dmRepository.hideConversation(event.channelId);
    } catch (e, s) {
      Logger.e('DM 숨기기 실패', tag: 'PersonalChat', error: e, stackTrace: s);
      if (isClosed) return;
      _conversations = [..._conversations]
        ..insert(index.clamp(0, _conversations.length), hidden);
      _emit(emit, error: failureMessageOf(e, 'DM을 숨기지 못했어요.'));
    } finally {
      _hiding.remove(event.channelId);
    }
  }

  void _onSocketEvent(SocketEvent event) {
    if (event.name != 'message') return;
    if (_rooms.contains(event.data['channelId'])) {
      add(const PersonalChatEvent.refreshed());
    }
  }

  /// 대화와 상대 이름을 읽어 화면 목록으로. 이름을 못 읽어도 목록은 보여 준다.
  Future<List<DirectMessagePreview>> _fetch() async {
    final conversations = await _dmRepository.fetchConversations();
    await _fetchNames(conversations);
    final myId = ProfileStore.instance.currentUserId;
    final now = DateTime.now();
    final previews = [
      for (final conversation in conversations)
        if (!_hiding.contains(conversation.channelId))
          directMessagePreviewOf(
            conversation,
            _otherOf(conversation),
            myId: myId,
            now: now,
          ),
    ];
    _syncRooms({for (final preview in previews) preview.channelId});
    return previews;
  }

  Future<void> _fetchNames(List<DmConversationResponse> conversations) async {
    final unknown = {
      for (final conversation in conversations)
        if (conversation.otherUserId case final id?)
          if (!_names.containsKey(id)) id,
    };
    if (unknown.isEmpty) return;
    try {
      for (final user in await _messageRepository.fetchDisplayNames(unknown)) {
        _names[user.id] = user.nickname?.isNotEmpty == true
            ? user.nickname!
            : user.name;
      }
    } catch (e, s) {
      Logger.e('DM 상대 이름 조회 실패', tag: 'PersonalChat', error: e, stackTrace: s);
    }
  }

  ProfileEntity _otherOf(DmConversationResponse conversation) {
    final id = conversation.otherUserId;
    return id == null
        ? unknownChatAuthor(0)
        : chatAuthorOf(id, _names[id] ?? '');
  }

  /// 목록에 있는 대화의 방에만 들어가 있게 맞춘다.
  void _syncRooms(Set<int> channelIds) {
    // 닫힌 뒤에 끝난 읽기가 방에 다시 들어가면 나가는 쪽이 없다.
    if (isClosed) return;
    for (final id in _rooms.difference(channelIds)) {
      _socket.leaveChannel(id);
    }
    for (final id in channelIds.difference(_rooms)) {
      _socket.joinChannel(id);
    }
    _rooms
      ..clear()
      ..addAll(channelIds);
  }

  /// [error] 가 있으면 같은 사유로 연달아 실패해도 화면이 매번 알리게 사유 없는 상태를
  /// 먼저 낸다(같은 상태는 무시되므로).
  void _emit(Emitter<PersonalChatState> emit, {String? error}) {
    final data = PersonalChatData(conversations: _conversations);
    if (error != null) emit(PersonalChatState.success(data));
    emit(
      PersonalChatState.success(error == null ? data : data.withError(error)),
    );
  }

  @override
  Future<void> close() async {
    _retryTimer?.cancel();
    await _socketEvents.cancel();
    await _reconnects.cancel();
    for (final id in _rooms) {
      _socket.leaveChannel(id);
    }
    _rooms.clear();
    return super.close();
  }
}
