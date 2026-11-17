import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../chat/data/model/chat_message_mapping.dart';
import '../../../../chat/data/repositories/message_repository.dart';
import '../../../data/repositories/channel_repository.dart';
import '../../../domain/channel_member.dart';

part 'channel_members_event.dart';
part 'channel_members_state.dart';

/// 채널 멤버 화면 상태를 관리하는 Bloc.
///
/// 서버가 사용자 id 만 줘서, 이름은 user 서비스에서 한꺼번에 읽어 채운다. 이름을 못
/// 읽어도 멤버 목록은 보여 준다.
class ChannelMembersBloc
    extends Bloc<ChannelMembersEvent, ChannelMembersState> {
  ChannelMembersBloc({
    required this.channelId,
    required ChannelRepository channelRepository,
    required MessageRepository messageRepository,
  }) : _channelRepository = channelRepository,
       _messageRepository = messageRepository,
       super(const ChannelMembersState.initial()) {
    on<ChannelMembersRequested>(_onLoad);
  }

  final int channelId;
  final ChannelRepository _channelRepository;
  final MessageRepository _messageRepository;

  Future<void> _onLoad(
    ChannelMembersRequested event,
    Emitter<ChannelMembersState> emit,
  ) async {
    emit(const ChannelMembersState.loading());
    try {
      // 채널과 멤버는 같이 보내고, 하나라도 실패하면 그 예외를 그대로 받는다.
      final headerRequest = _channelRepository.fetchChannelHeader(channelId);
      final membersRequest = _channelRepository.fetchMembers(channelId);
      await Future.wait([headerRequest, membersRequest], eagerError: true);
      final header = await headerRequest;
      final members = await membersRequest;
      final names = await _fetchNames([for (final m in members) m.userId]);

      emit(
        ChannelMembersState.success((
          channelName: header.name,
          members: [
            for (final member in members)
              ChannelMember(
                profile: chatAuthorOf(
                  member.userId,
                  names[member.userId] ?? '',
                ),
                avatarColor: chatAvatarColorOf(member.userId),
              ),
          ],
        )),
      );
    } catch (e, s) {
      Logger.e('채널 멤버 조회 실패', tag: 'ChannelMembers', error: e, stackTrace: s);
      emit(
        ChannelMembersState.failure(
          e is DioException ? dioErrorMessage(e) : null,
        ),
      );
    }
  }

  /// 사용자 id → 표시 이름. 못 읽으면 빈 맵이라 멤버가 `알 수 없음` 으로 보인다.
  Future<Map<int, String>> _fetchNames(List<int> userIds) async {
    try {
      return {
        for (final user in await _messageRepository.fetchDisplayNames(userIds))
          user.id: displayNameOf(user),
      };
    } catch (e, s) {
      Logger.e(
        '채널 멤버 이름 조회 실패',
        tag: 'ChannelMembers',
        error: e,
        stackTrace: s,
      );
      return const {};
    }
  }
}
