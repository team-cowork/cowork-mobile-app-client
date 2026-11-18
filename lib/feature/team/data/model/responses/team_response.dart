import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_response.freezed.dart';
part 'team_response.g.dart';

/// `GET /teams/{teamId}`, `PATCH /teams/{teamId}` 응답. 팀 상세.
@freezed
abstract class TeamResponse with _$TeamResponse {
  const factory TeamResponse({
    required int id,
    @Default('') String name,

    /// 정한 적 없으면 null, 지웠으면 빈 문자열로 온다.
    String? description,

    /// 아이콘이 없으면 null.
    String? iconUrl,

    /// 소유자 사용자 id.
    int? ownerId,
  }) = _TeamResponse;

  factory TeamResponse.fromJson(Map<String, dynamic> json) =>
      _$TeamResponseFromJson(json);
}
