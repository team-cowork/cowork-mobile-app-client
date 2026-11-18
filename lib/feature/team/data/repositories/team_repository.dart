import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../shared/utils/image_content_type.dart';
import '../../../auth/data/auth_repository.dart';
import '../../domain/enums/team_permission.dart';
import '../model/invite_duration.dart';
import '../model/requests/confirm_team_icon_request.dart';
import '../model/requests/create_invite_request.dart';
import '../model/requests/create_team_request.dart';
import '../model/requests/invite_members_request.dart';
import '../model/requests/team_icon_upload_request.dart';
import '../model/requests/update_team_icon_request.dart';
import '../model/requests/update_team_request.dart';
import '../model/responses/invite_response.dart';
import '../model/responses/join_team_response.dart';
import '../model/responses/team_icon_response.dart';
import '../model/responses/team_icon_upload_response.dart';
import '../model/responses/team_member_response.dart';
import '../model/responses/team_response.dart';
import '../model/responses/team_role_response.dart';
import '../model/responses/team_summary_response.dart';
import '../model/team_role_mapping.dart';

/// team 서비스의 팀 저장소.
class TeamRepository {
  TeamRepository(AuthRepository auth)
    : this.withDio(
        createAuthedDio(ApiService.team, auth),
        createDio(ApiService.team),
      );

  TeamRepository.withDio(this._dio, [Dio? uploader])
    : _uploader = uploader ?? _dio;

  final Dio _dio;

  /// 아이콘을 스토리지의 presigned URL 로 직접 올릴 때 쓰는 dio.
  ///
  /// [_dio] 를 쓰면 인터셉터가 Authorization 을 붙이는데, presigned 서명에 없는
  /// 헤더가 섞이면 스토리지가 요청을 거부한다. 그래서 인증 없는 dio 로 따로 보낸다.
  final Dio _uploader;

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

  /// 팀 상세. 팀 멤버만 읽을 수 있다.
  Future<TeamResponse> fetchTeam(int teamId) async => TeamResponse.fromJson(
    unwrapPayload((await _dio.get<String>('/teams/$teamId')).data ?? ''),
  );

  /// 팀 이름·설명 수정. `manage_team` 권한이 없으면 서버가 403 을 준다.
  Future<TeamResponse> updateTeam(
    int teamId,
    UpdateTeamRequest request,
  ) async => TeamResponse.fromJson(
    unwrapPayload(
      (await _dio.patch<String>(
            '/teams/$teamId',
            data: request.toJson(),
          )).data ??
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

  /// 내가([userId]) [team] 에서 할 수 있는 일.
  ///
  /// 소유자([TeamResponse.isOwnedBy])면 묻지 않고 모두 할 수 있다고 본다. 아니면 내 역할(모든 멤버에게
  /// 붙는 기본 역할 포함)을 읽어 정한다.
  ///
  /// 소유자는 서버가 모든 일을 허용하지만, 역할 조회에 그 권한이 실려 오지 않을 수 있다.
  /// 역할만 보면 소유자에게서 메뉴를 빼앗게 되어 소유자는 역할을 보지 않는다.
  Future<Set<TeamPermission>> fetchMyPermissions(
    TeamResponse team, {
    required int userId,
  }) async {
    if (team.isOwnedBy(userId)) return TeamPermission.values.toSet();
    return permissionsOf([
      for (final json in unwrapListPayload(
        (await _dio.get<String>(
              '/teams/${team.id}/members/$userId/roles',
            )).data ??
            '',
      ))
        TeamRoleResponse.fromJson(json),
    ]);
  }

  /// 팀 아이콘을 [path] 의 사진으로 바꾸고 새 아이콘 URL 을 돌려준다.
  ///
  /// presigned 발급 → 스토리지 PUT → 업로드 확인 → 팀에 연결, 4단계다. 확인까지만
  /// 하고 연결하지 않으면 업로드는 팀과 무관한 파일로 남는다.
  Future<String> uploadTeamIcon(int teamId, String path) async {
    // presigned 서명에 들어가므로 발급과 업로드가 같은 값을 써야 한다. 받을 수 있는
    // 형식인지는 서버가 정한다(못 받으면 발급이 400 으로 거절된다).
    final contentType = imageContentTypeOf(path);
    final presigned = TeamIconUploadResponse.fromJson(
      unwrapPayload(
        (await _dio.post<String>(
              '/teams/icon/presigned',
              data: TeamIconUploadRequest(contentType: contentType).toJson(),
            )).data ??
            '',
      ),
    );

    // Uint8List 는 dio 가 변환 없이 그대로 실어 보낸다. 갤러리에서 고른 사진 한
    // 장이고 고를 때 줄여 오므로 통째로 읽어도 부담이 없다.
    await _uploader.put<void>(
      presigned.uploadUrl,
      data: await File(path).readAsBytes(),
      options: Options(contentType: contentType),
    );

    final confirmed = TeamIconResponse.fromJson(
      unwrapPayload(
        (await _dio.post<String>(
              '/teams/icon/confirm',
              data: ConfirmTeamIconRequest(
                objectKey: presigned.objectKey,
              ).toJson(),
            )).data ??
            '',
      ),
    );

    // 응답은 보낸 URL 을 그대로 돌려줘서 읽지 않는다.
    await _dio.patch<String>(
      '/teams/$teamId/icon',
      data: UpdateTeamIconRequest(iconUrl: confirmed.iconUrl).toJson(),
    );
    return confirmed.iconUrl;
  }

  /// 팀 아이콘 제거. 아이콘이 없으면 서버가 404 를 준다.
  Future<void> removeTeamIcon(int teamId) =>
      _dio.delete<String>('/teams/$teamId/icon');

  /// 내가([userId]) 팀에서 나간다. 소유자는 소유권을 넘기기 전엔 나갈 수 없어 서버가
  /// 403 을 준다.
  Future<void> leaveTeam(int teamId, int userId) =>
      _dio.delete<String>('/teams/$teamId/members/$userId');

  /// 팀 삭제. 채널·멤버·역할이 함께 지워진다. `delete_team` 권한이 필요하다.
  Future<void> deleteTeam(int teamId) => _dio.delete<String>('/teams/$teamId');

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
