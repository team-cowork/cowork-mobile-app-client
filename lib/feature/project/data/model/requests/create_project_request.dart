import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_project_request.freezed.dart';
part 'create_project_request.g.dart';

/// `POST /projects` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class CreateProjectRequest with _$CreateProjectRequest {
  // 값이 없는 필드는 null 로 보내지 않고 뺀다.
  @JsonSerializable(includeIfNull: false, createFactory: false)
  const factory CreateProjectRequest({
    required int teamId,
    required String name,

    /// 프로젝트 설명. 없으면 보내지 않는다.
    String? description,
  }) = _CreateProjectRequest;
}
