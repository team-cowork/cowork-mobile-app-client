// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_role_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamMemberRoleResponse _$TeamMemberRoleResponseFromJson(
  Map<String, dynamic> json,
) => _TeamMemberRoleResponse(
  name: json['name'] as String? ?? '',
  isDefault: json['isDefault'] as bool? ?? false,
);

Map<String, dynamic> _$TeamMemberRoleResponseToJson(
  _TeamMemberRoleResponse instance,
) => <String, dynamic>{'name': instance.name, 'isDefault': instance.isDefault};
