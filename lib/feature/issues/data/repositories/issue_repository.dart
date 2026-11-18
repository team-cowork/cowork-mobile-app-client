import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../../domain/issue_target.dart';
import '../model/issue_mapping.dart';
import '../model/requests/create_comment_request.dart';
import '../model/requests/create_issue_request.dart';
import '../model/responses/github_comment_response.dart';
import '../model/responses/github_issue_response.dart';
import '../model/responses/github_label_response.dart';
import '../model/responses/project_github_repo_response.dart';
import '../model/responses/project_response.dart';

/// 프로젝트에 연결된 GitHub 저장소의 이슈 저장소. project 서비스를 쓴다.
///
/// 이슈와 댓글을 만드는 요청은 서버가 접수만 확인하고 GitHub 에는 비동기로 만든다.
/// 그래서 요청 직후 목록을 읽으면 아직 안 보일 수 있다.
class IssueRepository {
  IssueRepository(AuthRepository auth)
    : this.withDio(createAuthedDio(ApiService.project, auth));

  IssueRepository.withDio(this._dio);

  final Dio _dio;

  /// 내가 참여한 프로젝트 중 저장소가 연결된 첫 프로젝트와 그 첫 저장소. 없으면 null.
  Future<IssueTarget?> fetchTarget() async {
    final page = unwrapPayload(
      (await _dio.get<String>(
            '/projects/me',
            queryParameters: {'size': _projectPageSize},
          )).data ??
          '',
    )['content'];
    if (page is! List) return null;
    for (final json in page.whereType<Map<String, dynamic>>()) {
      final project = ProjectResponse.fromJson(json);
      final repos = [
        for (final repo in unwrapListPayload(
          (await _dio.get<String>(
                '/projects/${project.id}/github-repos',
              )).data ??
              '',
        ))
          ProjectGithubRepoResponse.fromJson(repo),
      ];
      if (repos.isEmpty) continue;
      return IssueTarget(
        projectId: project.id,
        repoId: repos.first.id,
        label: '${project.name} · ${repoNameOf(repos.first.githubRepoUrl)}',
      );
    }
    return null;
  }

  /// 저장소의 열린 이슈. 서버가 닫힌 이슈는 주지 않는다.
  Future<List<GithubIssueResponse>> fetchIssues(IssueTarget target) async => [
    for (final json in unwrapListPayload(
      (await _dio.get<String>(_issues(target))).data ?? '',
    ))
      GithubIssueResponse.fromJson(json),
  ];

  /// 저장소에 정의된 라벨.
  Future<List<GithubLabelResponse>> fetchLabels(IssueTarget target) async => [
    for (final json in unwrapListPayload(
      (await _dio.get<String>('${_issues(target)}/labels')).data ?? '',
    ))
      GithubLabelResponse.fromJson(json),
  ];

  Future<void> createIssue(IssueTarget target, CreateIssueRequest request) =>
      _dio.post<String>(_issues(target), data: request.toJson());

  Future<List<GithubCommentResponse>> fetchComments(
    IssueTarget target,
    int issueNumber,
  ) async => [
    for (final json in unwrapListPayload(
      (await _dio.get<String>(
            '${_issues(target)}/$issueNumber/comments',
          )).data ??
          '',
    ))
      GithubCommentResponse.fromJson(json),
  ];

  Future<void> createComment(
    IssueTarget target,
    int issueNumber,
    String body,
  ) => _dio.post<String>(
    '${_issues(target)}/$issueNumber/comments',
    data: CreateCommentRequest(body: body).toJson(),
  );

  static const _projectPageSize = 100;

  static String _issues(IssueTarget target) =>
      '/projects/${target.projectId}/github-repos/${target.repoId}/issues';
}
