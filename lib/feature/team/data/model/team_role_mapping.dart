import '../../domain/enums/team_permission.dart';
import 'responses/team_role_response.dart';

/// [roles] 를 가진 멤버가 할 수 있는 일.
///
/// cowork-team `RolePolicy.allows` 와 같은 규칙이다. 역할 중 하나라도 권한 키가 켜져
/// 있거나 `administrator` 가 켜져 있으면 허용한다. (서버에서 `administrator` 로 대신할
/// 수 없는 건 소유권 이양 하나인데, [TeamPermission] 에는 없다.)
Set<TeamPermission> permissionsOf(Iterable<TeamRoleResponse> roles) => {
  for (final permission in TeamPermission.values)
    if (roles.any(
      (role) =>
          role.permissions[_keyOf(permission)] == true ||
          role.permissions[_administrator] == true,
    ))
      permission,
};

/// cowork-team `PermissionKeys` 의 권한 키.
String _keyOf(TeamPermission permission) => switch (permission) {
  TeamPermission.manageTeam => 'manage_team',
  TeamPermission.deleteTeam => 'delete_team',
  TeamPermission.manageInvites => 'manage_invites',
};

const _administrator = 'administrator';
