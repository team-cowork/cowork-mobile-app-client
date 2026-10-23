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
import '../../../data/model/responses/message_response.dart';
import '../../../data/repositories/channel_repository.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../domain/chat_message.dart';

part 'channel_message_event.dart';
part 'channel_message_state.dart';

/// 채널 대화 화면 상태를 관리하는 Bloc.
///
/// 채널 머리와 최근 메시지를 읽고, 위로 올리면 그보다 이전 메시지를 이어 붙인다.
class ChannelMessageBloc
    extends Bloc<ChannelMessageEvent, ChannelMessageState> {
  ChannelMessageBloc({
    required this.channelId,
    required ChannelRepository channelRepository,
    required MessageRepository messageRepository,
    required ProfileRepository profileRepository,
    required ChatSocket socket,
  }) : _channelRepository = channelRepository,
       _messageRepository = messageRepository,
       _profileRepository = profileRepository,
       _socket = socket,
       super(const ChannelMessageState.initial()) {
    on<ChannelMessageRequested>(_onLoad);
    on<ChannelMessageOlderRequested>(_onLoadOlder);

    // 이 채널 메시지 이벤트는 채널 방으로 온다. 읽기 전에 들어가 둔다.
    _socket.joinChannel(channelId);
  }

  final int channelId;

  final ChannelRepository _channelRepository;
  final MessageRepository _messageRepository;
  final ProfileRepository _profileRepository;
  final ChatSocket _socket;

  /// 채널 머리. 불러오기에 성공하면 채워진다.
  ({String name, String description})? _header;

  /// 보이는 메시지. 오래된 것부터 최신 순이다.
  final _messages = <MessageResponse>[];

  /// 작성자 id 별 표시 이름.
  final _authors = <int, ProfileEntity>{};

  bool _hasOlder = false;
  bool _loadingOlder = false;

  Future<void> _onLoad(
    ChannelMessageRequested event,
    Emitter<ChannelMessageState> emit,
  ) async {
    emit(const ChannelMessageState.loading());
    _header = null;
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
      if (myId != null) _authors[myId] = chatAuthorOf(myId, me.name ?? '');
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

    _emit(emit);
  }

  Future<void> _onLoadOlder(
    ChannelMessageOlderRequested event,
    Emitter<ChannelMessageState> emit,
  ) async {
    final oldest = _messages.firstOrNull;
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
          chatMessageOf(message, _authorOf(message), now: now),
      ],
      hasOlder: _hasOlder,
      loadingOlder: _loadingOlder,
    );
  }

  ProfileEntity _authorOf(MessageResponse message) => message.isSystem
      ? systemChatAuthor(message.authorId)
      : _authors[message.authorId] ?? unknownChatAuthor(message.authorId);

  @override
  Future<void> close() {
    _socket.leaveChannel(channelId);
    return super.close();
  }

  static String _reasonOf(String fallback, Object error) =>
      error is DioException ? dioErrorMessage(error) : fallback;
}
