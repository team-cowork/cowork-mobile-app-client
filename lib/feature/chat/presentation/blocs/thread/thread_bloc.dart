import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/chat_socket.dart';
import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../shared/domain/profile_entity.dart';
import '../../../../../shared/utils/client_message_id.dart';
import '../../../../channel/data/repositories/channel_repository.dart';
import '../../../data/model/chat_message_mapping.dart';
import '../../../data/model/message_socket_event.dart';
import '../../../data/model/requests/send_message_request.dart';
import '../../../data/model/responses/message_response.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../domain/message_thread.dart';

part 'thread_event.dart';
part 'thread_state.dart';

/// 스레드 화면 상태를 관리하는 Bloc.
///
/// 스레드는 [parentMessageId] 메시지와 거기에 달린 답글이다. 답글을 읽은 뒤에는 채널
/// 방을 소켓으로 구독해 새 답글·수정·삭제를 반영한다. 전송은 서버가 큐에 넣고 바로
/// 돌아오므로, 저장된 답글이 소켓으로 와야 목록에 나타난다. 그 답글이
/// [confirmTimeout] 안에 오지 않거나 소켓이 끊김 복구 없이 다시 붙으면 답글을 다시 읽어
/// 맞춘다.
class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  ThreadBloc({
    required this.channelId,
    required this.parentMessageId,
    required ChannelRepository channelRepository,
    required MessageRepository messageRepository,
    required ChatSocket socket,
    this.confirmTimeout = const Duration(seconds: 10),
  }) : _channelRepository = channelRepository,
       _messageRepository = messageRepository,
       _socket = socket,
       super(const ThreadState.initial()) {
    on<ThreadRequested>(_onLoad);
    on<ThreadReplySent>(_onSend);
    on<_ThreadSocketEventReceived>(_onSocketEvent);
    on<_ThreadAuthorsResolved>(_onAuthorsResolved);
    on<_ThreadConfirmTimedOut>(_onConfirmTimedOut);
    on<_ThreadResynced>(_onResynced);

    _socketEvents = _socket.events
        .map(MessageSocketEvent.from)
        .where((event) => event != null)
        .listen((event) => add(_ThreadSocketEventReceived(event!)));
    _reconnects = _socket.reconnected.listen(
      (_) => add(const _ThreadResynced()),
    );
    // 답글을 읽는 사이에 온 것도 받도록 읽기 전에 들어간다.
    _socket.joinChannel(channelId);
  }

  final int channelId;

  /// 스레드의 부모(맨 위) 메시지 id.
  final String parentMessageId;

  /// 보낸 답글이 소켓으로 저장돼 오기를 기다리는 시간.
  final Duration confirmTimeout;

  final ChannelRepository _channelRepository;
  final MessageRepository _messageRepository;
  final ChatSocket _socket;
  late final StreamSubscription<MessageSocketEvent?> _socketEvents;
  late final StreamSubscription<void> _reconnects;

  String? _channelName;

  /// 부모 메시지. 불러오기에 성공하면 채워진다.
  MessageResponse? _root;

  /// 부모 메시지가 지워졌다. 답글을 달 곳이 없어 화면을 실패로 바꾼다.
  bool _rootDeleted = false;

  /// 보이는 답글. 오래된 것부터 최신 순이다.
  final _replies = <MessageResponse>[];

  /// 작성자 id 별 표시 이름.
  final _authors = <int, ProfileEntity>{};

  /// 이름을 받아 오는 중인 작성자. 같은 사람을 여러 번 묻지 않는다.
  final _resolving = <int>{};

  /// 답글을 읽는 동안 온 소켓 이벤트. 목록을 받은 뒤 순서대로 반영한다.
  final _pending = <MessageSocketEvent>[];

  /// 보낸 답글(`clientMessageId`)별 저장 확인 타이머.
  final _confirmTimers = <String, Timer>{};

  Future<void> _onLoad(
    ThreadRequested event,
    Emitter<ThreadState> emit,
  ) async {
    emit(const ThreadState.loading());
    _root = null;
    _rootDeleted = false;
    _pending.clear();
    try {
      final headerRequest = _channelRepository.fetchChannelHeader(channelId);
      final rootRequest = _messageRepository.fetchMessage(
        channelId,
        parentMessageId,
      );
      final repliesRequest = _messageRepository.fetchReplies(
        channelId,
        parentMessageId,
      );
      // 셋은 같이 보내고, 하나라도 실패하면 그 예외를 그대로 받는다.
      await Future.wait([
        headerRequest,
        rootRequest,
        repliesRequest,
      ], eagerError: true);
      final header = await headerRequest;
      final root = await rootRequest;
      final replies = await repliesRequest;
      await _fetchAuthors([root, ...replies]);

      _channelName = header.name;
      _root = root;
      _replies
        ..clear()
        ..addAll(replies.reversed);
    } catch (e, s) {
      Logger.e('스레드 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      emit(ThreadState.failure(e is DioException ? dioErrorMessage(e) : null));
      return;
    }

    for (final change in _pending) {
      _apply(change);
    }
    _pending.clear();
    _emit(emit);
  }

  Future<void> _onSend(ThreadReplySent event, Emitter<ThreadState> emit) async {
    final text = event.text.trim();
    if (_root == null || text.isEmpty) return;

    final clientMessageId = newClientMessageId();
    try {
      await _messageRepository.sendMessage(
        channelId,
        SendMessageRequest(
          content: text,
          clientMessageId: clientMessageId,
          parentMessageId: parentMessageId,
        ),
      );
    } catch (e, s) {
      Logger.e('답글 전송 실패', tag: 'Chat', error: e, stackTrace: s);
      _emit(emit, error: _reasonOf('답글을 보내지 못했어요.', e));
      return;
    }
    // 전송 응답보다 저장된 답글이 소켓으로 먼저 왔으면 기다릴 것이 없다.
    if (!_hasReply(clientMessageId) && !isClosed) {
      _confirmTimers[clientMessageId] = Timer(
        confirmTimeout,
        () => add(_ThreadConfirmTimedOut(clientMessageId)),
      );
    }
  }

  void _onSocketEvent(
    _ThreadSocketEventReceived event,
    Emitter<ThreadState> emit,
  ) {
    if (_root == null) {
      _pending.add(event.event);
      return;
    }
    if (_apply(event.event)) _emit(emit);
  }

  /// 보낸 답글이 소켓으로 오지 않았다. 답글을 다시 읽어 보고, 그래도 없으면 저장되지
  /// 않은 것으로 보고 알린다.
  Future<void> _onConfirmTimedOut(
    _ThreadConfirmTimedOut event,
    Emitter<ThreadState> emit,
  ) async {
    _confirmTimers.remove(event.clientMessageId);
    if (_hasReply(event.clientMessageId)) return;
    try {
      await _syncReplies();
    } catch (e, s) {
      Logger.e('보낸 답글 확인 실패', tag: 'Chat', error: e, stackTrace: s);
    }
    if (_hasReply(event.clientMessageId)) {
      _emit(emit);
      return;
    }
    _emit(emit, error: '답글이 전송되지 않았어요. 다시 보내 주세요.');
  }

  /// 소켓이 끊김 복구 없이 다시 붙었다. 끊긴 동안의 변경을 다시 읽어 맞춘다.
  Future<void> _onResynced(
    _ThreadResynced event,
    Emitter<ThreadState> emit,
  ) async {
    if (_root == null) return;
    try {
      await _syncReplies();
    } catch (e, s) {
      Logger.e('재연결 후 답글 동기화 실패', tag: 'Chat', error: e, stackTrace: s);
      return;
    }
    _emit(emit);
  }

  void _onAuthorsResolved(
    _ThreadAuthorsResolved event,
    Emitter<ThreadState> emit,
  ) {
    for (final author in event.authors) {
      _authors[author.id] = author;
    }
    if (_root != null) _emit(emit);
  }

  /// 소켓 이벤트를 부모 메시지·[_replies] 에 반영한다. 바뀐 게 있으면 true.
  bool _apply(MessageSocketEvent event) {
    switch (event) {
      case MessageReceived(:final message):
        if (message.channelId != channelId ||
            message.parentMessageId != parentMessageId) {
          return false;
        }
        final index = _replies.indexWhere((other) => other.id == message.id);
        if (index == -1) {
          _replies.add(message);
        } else {
          _replies[index] = message;
        }
        _confirmTimers.remove(message.clientMessageId)?.cancel();
        if (!message.isSystem && !_authors.containsKey(message.authorId)) {
          _resolveAuthorsLater([message.authorId]);
        }
        return true;
      case MessageEdited(:final messageId, :final content):
        final root = _root;
        if (root != null && root.id == messageId) {
          _root = root.copyWith(content: content);
          return true;
        }
        final index = _replies.indexWhere((other) => other.id == messageId);
        if (index == -1) return false;
        _replies[index] = _replies[index].copyWith(content: content);
        return true;
      case MessageDeleted(:final messageId):
        if (_root?.id == messageId) {
          _rootDeleted = true;
          return true;
        }
        final before = _replies.length;
        _replies.removeWhere((other) => other.id == messageId);
        return _replies.length != before;
      case ChannelAccessLost():
        // 채널 화면이 사유를 알리고 위에 열린 스레드까지 걷는다.
        return false;
    }
  }

  /// 답글을 처음부터 다시 읽어 [_replies] 와 맞춘다.
  ///
  /// 읽은 범위 안의 답글은 서버 것으로 바꾸고(그 사이 지워진 것은 빠진다), 읽는 사이
  /// 소켓으로 먼저 온 더 최근 답글은 그 뒤에 둔다.
  Future<void> _syncReplies() async {
    final fetched = await _messageRepository.fetchReplies(
      channelId,
      parentMessageId,
    );
    await _fetchAuthors(fetched);

    final fetchedIds = {for (final reply in fetched) reply.id};
    final newest = fetched.firstOrNull;
    final newer = [
      for (final reply in _replies)
        if (!fetchedIds.contains(reply.id) &&
            (newest == null || reply.createdAt.isAfter(newest.createdAt)))
          reply,
    ];
    for (final reply in fetched) {
      _confirmTimers.remove(reply.clientMessageId)?.cancel();
    }
    _replies
      ..clear()
      ..addAll(fetched.reversed)
      ..addAll(newer);
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

  /// 소켓으로 온 답글의 작성자 이름을 기다리지 않고 받아 온다. 그동안은
  /// [unknownChatAuthor] 로 보이고, 받아 오면 [_ThreadAuthorsResolved] 로 바꾼다.
  void _resolveAuthorsLater(Iterable<int> authorIds) {
    final ids = authorIds.where(_resolving.add).toList();
    if (ids.isEmpty) return;
    _messageRepository
        .fetchDisplayNames(ids)
        .then((users) {
          if (isClosed) return;
          add(
            _ThreadAuthorsResolved([
              for (final user in users) chatAuthorOf(user.id, user.name),
            ]),
          );
        })
        .catchError((Object e, StackTrace s) {
          Logger.e('작성자 이름 조회 실패', tag: 'Chat', error: e, stackTrace: s);
        })
        .whenComplete(() => _resolving.removeAll(ids));
  }

  void _emit(Emitter<ThreadState> emit, {String? error}) {
    final root = _root;
    final channelName = _channelName;
    if (root == null || channelName == null) return;
    if (_rootDeleted) {
      emit(const ThreadState.failure('원본 메시지가 삭제됐어요.'));
      return;
    }
    final now = DateTime.now();
    final thread = MessageThread(
      channelName: channelName,
      rootMessage: chatMessageOf(root, _authorOf(root), now: now),
      replies: [
        for (final reply in _replies)
          chatMessageOf(reply, _authorOf(reply), now: now),
      ],
    );
    // 같은 사유로 연달아 실패하면 상태가 같아 무시된다. 사유 없는 상태를 먼저 내서
    // 화면이 매번 알리게 한다.
    if (error != null) emit(ThreadState.success(thread));
    emit(ThreadState.success(error == null ? thread : thread.withError(error)));
  }

  ProfileEntity _authorOf(MessageResponse message) => message.isSystem
      ? systemChatAuthor(message.authorId)
      : _authors[message.authorId] ?? unknownChatAuthor(message.authorId);

  bool _hasReply(String clientMessageId) =>
      _replies.any((reply) => reply.clientMessageId == clientMessageId);

  static String _reasonOf(String fallback, Object error) =>
      error is DioException ? dioErrorMessage(error) : fallback;

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
}
