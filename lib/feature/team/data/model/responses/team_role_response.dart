import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_role_response.freezed.dart';
part 'team_role_response.g.dart';

/// `GET /teams/{teamId}/members/{userId}/roles` 응답 원소. 멤버가 가진 역할 하나.
///
/// 앱은 권한 판단에만 쓰므로 [permissions] 외의 필드(색상·우선순위 등)는 받지 않는다.
@freezed
abstract class TeamRoleResponse with _$TeamRoleResponse {
  const factory TeamRoleResponse({
    required int id,
    @Default('') String name,

    /// 권한 키(`manage_team` 등)별 허용 여부. 서버는 모든 키를 채워 보낸다.
    @Default({}) Map<String, bool> permissions,
  }) = _TeamRoleResponse;

  factory TeamRoleResponse.fromJson(Map<String, dynamic> json) =>
      _$TeamRoleResponseFromJson(json);
}
