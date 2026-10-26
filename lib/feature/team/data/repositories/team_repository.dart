import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../model/requests/create_team_request.dart';
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

  /// 팀을 만들고 서버가 저장한 팀을 돌려준다. 만든 사람이 소유자가 된다.
  Future<TeamSummaryResponse> createTeam(CreateTeamRequest request) async =>
      TeamSummaryResponse.fromJson(
        unwrapPayload(
          (await _dio.post<String>('/teams', data: request.toJson())).data ??
              '',
        ),
      );
}
