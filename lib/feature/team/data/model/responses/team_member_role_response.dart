import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_member_role_response.freezed.dart';
part 'team_member_role_response.g.dart';

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
