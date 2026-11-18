import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_issue_request.freezed.dart';
part 'create_issue_request.g.dart';

/// 이슈 생성 요청 본문. 서버는 접수만 확인하고 GitHub 에는 비동기로 만든다.
@Freezed(fromJson: false, toJson: true)
abstract class CreateIssueRequest with _$CreateIssueRequest {
  @JsonSerializable(includeIfNull: false)
  const factory CreateIssueRequest({
    required String title,
    String? body,

    /// 만들면서 붙일 라벨 하나.
    String? label,
  }) = _CreateIssueRequest;
}
