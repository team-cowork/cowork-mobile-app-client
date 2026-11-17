import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_member_response.freezed.dart';
part 'team_member_response.g.dart';

/// `GET /teams/{teamId}/members` 응답의 팀 멤버 하나.
@freezed
abstract class TeamMemberResponse with _$TeamMemberResponse {
  const factory TeamMemberResponse({
    required int userId,

    /// `OWNER` / `ADMIN` / `MEMBER`.
    @Default('MEMBER') String role,

    /// 사용자가 받은 커스텀 역할. 모든 멤버에게 자동으로 붙는 기본 역할도 들어 있다.
    @Default([]) List<TeamMemberRoleResponse> roles,
  }) = _TeamMemberResponse;

  factory TeamMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberResponseFromJson(json);
}

/// 팀 멤버가 받은 커스텀 역할 하나.
@freezed
abstract class TeamMemberRoleResponse with _$TeamMemberRoleResponse {
  const factory TeamMemberRoleResponse({
    @Default('') String name,

    /// 활성 멤버 모두에게 자동으로 붙는 기본 역할인지.
    @Default(false) bool isDefault,
  }) = _TeamMemberRoleResponse;

  factory TeamMemberRoleResponse.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberRoleResponseFromJson(json);
}
