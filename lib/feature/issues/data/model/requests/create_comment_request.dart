import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_comment_request.freezed.dart';
part 'create_comment_request.g.dart';

/// 이슈 댓글 작성 요청 본문. 서버는 접수만 확인한다.
@Freezed(fromJson: false, toJson: true)
abstract class CreateCommentRequest with _$CreateCommentRequest {
  const factory CreateCommentRequest({required String body}) =
      _CreateCommentRequest;
}
