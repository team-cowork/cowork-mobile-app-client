// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamMemberResponse _$TeamMemberResponseFromJson(Map<String, dynamic> json) =>
    _TeamMemberResponse(
      userId: (json['userId'] as num).toInt(),
      role: json['role'] as String? ?? 'MEMBER',
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map(
                (e) =>
                    TeamMemberRoleResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TeamMemberResponseToJson(_TeamMemberResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'role': instance.role,
      'roles': instance.roles,
    };

_TeamMemberRoleResponse _$TeamMemberRoleResponseFromJson(
  Map<String, dynamic> json,
) => _TeamMemberRoleResponse(
  name: json['name'] as String? ?? '',
  isDefault: json['isDefault'] as bool? ?? false,
);

Map<String, dynamic> _$TeamMemberRoleResponseToJson(
  _TeamMemberRoleResponse instance,
) => <String, dynamic>{'name': instance.name, 'isDefault': instance.isDefault};
