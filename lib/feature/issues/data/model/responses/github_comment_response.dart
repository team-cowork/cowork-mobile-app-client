import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_comment_response.freezed.dart';
part 'github_comment_response.g.dart';

/// 이슈 댓글 목록 응답의 댓글 하나.
@freezed
abstract class GithubCommentResponse with _$GithubCommentResponse {
  const factory GithubCommentResponse({
    required int id,

    /// 작성자 GitHub 사용자명.
    @Default('') String author,
    @Default('') String body,
    required DateTime createdAt,
  }) = _GithubCommentResponse;

  factory GithubCommentResponse.fromJson(Map<String, dynamic> json) =>
      _$GithubCommentResponseFromJson(json);
}
