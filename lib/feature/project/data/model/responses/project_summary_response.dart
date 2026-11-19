import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_summary_response.freezed.dart';
part 'project_summary_response.g.dart';

/// `GET /projects?teamId=` 응답 페이지의 프로젝트 하나. `POST /projects` 응답도 같다.
///
/// 채팅 홈에서 채널을 묶는 카테고리로 쓴다. 화면에서 쓰는 필드만 옮긴다.
@freezed
abstract class ProjectSummaryResponse with _$ProjectSummaryResponse {
  const factory ProjectSummaryResponse({
    /// 채널의 `projectId` 와 맞춰 묶으므로 필수다. 없으면 fromJson 이 던진다.
    required int id,
    @Default('') String name,
  }) = _ProjectSummaryResponse;

  factory ProjectSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$ProjectSummaryResponseFromJson(json);
}
