import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_issue_response.freezed.dart';
part 'github_issue_response.g.dart';

/// 저장소 이슈 목록 응답의 이슈 하나. 서버는 열린 이슈만 준다.
@freezed
abstract class GithubIssueResponse with _$GithubIssueResponse {
  const factory GithubIssueResponse({
    required int number,
    @Default('') String title,

    /// 작성자 GitHub 사용자명.
    @Default('') String author,
    @Default('open') String state,
    @Default('') String htmlUrl,
    @Default([]) List<String> labels,
    required DateTime createdAt,
  }) = _GithubIssueResponse;

  factory GithubIssueResponse.fromJson(Map<String, dynamic> json) =>
      _$GithubIssueResponseFromJson(json);
}
