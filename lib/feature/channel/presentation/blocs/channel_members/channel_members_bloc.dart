import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../shared/utils/chat_author.dart';
import '../../../../profile/data/repositories/profile_repository.dart';
import '../../../../team/data/model/responses/team_member_response.dart';
import '../../../../team/data/repositories/team_repository.dart';
import '../../../data/model/channel_member_mapping.dart';
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
    required ProfileRepository profileRepository,
    required TeamRepository teamRepository,
  }) : _channelRepository = channelRepository,
       _profileRepository = profileRepository,
       _teamRepository = teamRepository,
       super(const ChannelMembersState.initial()) {
    on<ChannelMembersRequested>(_onLoad);
  }

  final int channelId;
  final ChannelRepository _channelRepository;
  final ProfileRepository _profileRepository;
  final TeamRepository _teamRepository;

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
      // 이름과 역할은 서로의 결과를 쓰지 않고 둘 다 안에서 실패를 받으니 같이 보낸다.
      final namesRequest = _fetchNames([for (final m in members) m.userId]);
      final teamMembersRequest = _fetchTeamMembers(header.teamId);
      final names = await namesRequest;
      final teamMembers = await teamMembersRequest;

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
                role: channelMemberRoleOf(teamMembers[member.userId]),
                roleNames: channelMemberRoleNamesOf(teamMembers[member.userId]),
              ),
          ],
        )),
      );
    } catch (e, s) {
      Logger.e('채널 멤버 조회 실패', tag: 'ChannelMembers', error: e, stackTrace: s);
      emit(ChannelMembersState.failure(failureMessageOf(e)));
    }
  }

  /// 사용자 id → 팀 멤버. 못 읽으면 빈 맵이라 역할 없이 목록만 보인다.
  Future<Map<int, TeamMemberResponse>> _fetchTeamMembers(int? teamId) async {
    if (teamId == null) return const {};
    try {
      return {
        for (final member in await _teamRepository.fetchMembers(teamId))
          member.userId: member,
      };
    } catch (e, s) {
      Logger.e(
        '채널 멤버 역할 조회 실패',
        tag: 'ChannelMembers',
        error: e,
        stackTrace: s,
      );
      return const {};
    }
  }

  /// 사용자 id → 표시 이름. 못 읽으면 빈 맵이라 멤버가 `알 수 없음` 으로 보인다.
  Future<Map<int, String>> _fetchNames(List<int> userIds) async {
    try {
      return {
        for (final user in await _profileRepository.fetchDisplayNames(userIds))
          user.id: user.displayName,
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
