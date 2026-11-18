import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../model/requests/create_project_request.dart';
import '../model/responses/project_summary_response.dart';

/// project 서비스의 프로젝트 저장소.
class ProjectRepository {
  ProjectRepository(AuthRepository auth)
    : this.withDio(createAuthedDio(ApiService.project, auth));

  ProjectRepository.withDio(this._dio);

  final Dio _dio;

  /// 팀에서 내가 볼 수 있는 프로젝트를 서버 순서(position) 그대로.
  ///
  /// 페이지 응답이지만 팀 프로젝트는 많지 않아 웹처럼 한 쪽에 크게 받는다.
  Future<List<ProjectSummaryResponse>> fetchTeamProjects(int teamId) async {
    final content = unwrapPayload(
      (await _dio.get<String>(
            '/projects',
            queryParameters: {'teamId': teamId, 'size': _pageSize},
          )).data ??
          '',
    )['content'];
    if (content is! List) return const [];
    return [
      for (final json in content.whereType<Map<String, dynamic>>())
        ProjectSummaryResponse.fromJson(json),
    ];
  }

  /// 프로젝트를 만들고 서버가 저장한 프로젝트를 돌려준다.
  Future<ProjectSummaryResponse> createProject(
    CreateProjectRequest request,
  ) async => ProjectSummaryResponse.fromJson(
    unwrapPayload(
      (await _dio.post<String>('/projects', data: request.toJson())).data ?? '',
    ),
  );

  static const _pageSize = 100;
}
