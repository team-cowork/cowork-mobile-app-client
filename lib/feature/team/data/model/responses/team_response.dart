import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_response.freezed.dart';
part 'team_response.g.dart';

/// `GET /teams/{teamId}`, `PATCH /teams/{teamId}` 응답. 팀 상세.
@freezed
abstract class TeamResponse with _$TeamResponse {
  const TeamResponse._();

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

  /// [userId] 가 이 팀의 소유자인지. 소유자는 팀 상세의 [ownerId] 로만 판단한다.
  /// 팀 목록의 `myRole` 은 서버가 권한 판정에 쓰지 않는 표시값이다.
  bool isOwnedBy(int userId) => ownerId == userId;
}
