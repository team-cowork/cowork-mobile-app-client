import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_github_repo_response.freezed.dart';
part 'project_github_repo_response.g.dart';

/// `GET /project/projects/{projectId}/github-repos` 응답의 연결된 저장소 하나.
@freezed
abstract class ProjectGithubRepoResponse with _$ProjectGithubRepoResponse {
  const factory ProjectGithubRepoResponse({
    required int id,
    @Default('') String githubRepoUrl,
  }) = _ProjectGithubRepoResponse;

  factory ProjectGithubRepoResponse.fromJson(Map<String, dynamic> json) =>
      _$ProjectGithubRepoResponseFromJson(json);
}
