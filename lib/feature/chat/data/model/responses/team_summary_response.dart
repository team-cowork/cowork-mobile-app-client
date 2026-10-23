import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_summary_response.freezed.dart';
part 'team_summary_response.g.dart';

/// `GET /teams` 응답 원소. 내가 속한 팀 하나.
///
/// 게이트웨이 envelope 을 벗긴 `data` 배열의 원소를 받는다(`unwrapListPayload`).
/// `POST /teams` 응답도 화면에서 쓰는 id·이름이 같아 이 모델로 받는다.
@freezed
abstract class TeamSummaryResponse with _$TeamSummaryResponse {
  const factory TeamSummaryResponse({
    /// 없으면 채널을 읽을 수도 만들 수도 없으므로 필수다. 없으면 fromJson 이 던진다.
    required int id,
    @Default('') String name,
  }) = _TeamSummaryResponse;

  factory TeamSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$TeamSummaryResponseFromJson(json);
}
