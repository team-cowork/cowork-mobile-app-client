import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../model/invite_duration.dart';
import '../model/requests/create_invite_request.dart';
import '../model/requests/create_team_request.dart';
import '../model/requests/invite_members_request.dart';
import '../model/responses/invite_response.dart';
import '../model/responses/join_team_response.dart';
import '../model/responses/team_member_response.dart';
import '../model/responses/team_summary_response.dart';

/// team 서비스의 팀 저장소.
class TeamRepository {
  TeamRepository(AuthRepository auth)
    : this.withDio(createAuthedDio(ApiService.team, auth));

  TeamRepository.withDio(this._dio);

  final Dio _dio;

  /// 내가 속한 팀 목록.
  Future<List<TeamSummaryResponse>> fetchMyTeams() async => [
    for (final json in unwrapListPayload(
      (await _dio.get<String>('/teams')).data ?? '',
    ))
      TeamSummaryResponse.fromJson(json),
  ];

  /// [teamId] 팀의 멤버와 역할. 팀 멤버면 누구나 읽을 수 있다.
  Future<List<TeamMemberResponse>> fetchMembers(int teamId) async => [
    for (final json in unwrapListPayload(
      (await _dio.get<String>('/teams/$teamId/members')).data ?? '',
    ))
      TeamMemberResponse.fromJson(json),
  ];

  /// 팀을 만들고 서버가 저장한 팀을 돌려준다. 만든 사람이 소유자가 된다.
  Future<TeamSummaryResponse> createTeam(CreateTeamRequest request) async =>
      TeamSummaryResponse.fromJson(
        unwrapPayload(
          (await _dio.post<String>('/teams', data: request.toJson())).data ??
              '',
        ),
      );

  /// [userIds] 사용자를 [teamId] 팀 멤버로 바로 넣는다. 받는 쪽 수락 절차는 없다.
  ///
  /// 이미 멤버인 사람은 서버가 건너뛴다. `manage_invites` 권한이 없으면 403.
  Future<void> inviteMembers(int teamId, List<int> userIds) async {
    await _dio.post<String>(
      '/teams/$teamId/members',
      data: InviteMembersRequest(userIds: userIds).toJson(),
    );
  }

  /// [teamId] 팀의 초대 코드를 [duration] 동안 쓸 수 있게 만든다.
  ///
  /// `manage_invites` 권한이 없으면 403.
  Future<InviteResponse> createInvite(
    int teamId,
    InviteDuration duration,
  ) async => InviteResponse.fromJson(
    unwrapPayload(
      (await _dio.post<String>(
            '/teams/$teamId/invites',
            data: CreateInviteRequest(duration: duration).toJson(),
          )).data ??
          '',
    ),
  );

  /// [teamId] 팀의 초대 코드. 만료·무효화된 코드도 섞여 온다.
  ///
  /// `manage_invites` 권한이 없으면 403.
  Future<List<InviteResponse>> fetchInvites(int teamId) async => [
    for (final json in unwrapListPayload(
      (await _dio.get<String>('/teams/$teamId/invites')).data ?? '',
    ))
      InviteResponse.fromJson(json),
  ];

  /// [inviteCode] 를 더는 못 쓰게 한다.
  ///
  /// 그 사이 다른 사람이 이미 무효화했으면(404) 원하던 결과라 성공으로 본다.
  Future<void> revokeInvite(int teamId, String inviteCode) async {
    try {
      await _dio.delete<String>(
        '/teams/$teamId/invites/${Uri.encodeComponent(inviteCode)}',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
    }
  }

  /// 초대 코드로 팀에 들어간다.
  ///
  /// 없는 코드는 404, 만료된 코드는 410, 이미 멤버면 409 로 실패한다.
  Future<JoinTeamResponse> joinTeam(String inviteCode) async =>
      JoinTeamResponse.fromJson(
        unwrapPayload(
          // 사용자가 직접 친 값이라 `/` 등이 섞여도 다른 경로로 새지 않게 인코딩한다.
          (await _dio.post<String>(
                '/teams/join/${Uri.encodeComponent(inviteCode)}',
              )).data ??
              '',
        ),
      );
}
