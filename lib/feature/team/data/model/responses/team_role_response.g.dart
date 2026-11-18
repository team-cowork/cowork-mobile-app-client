// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_role_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamRoleResponse _$TeamRoleResponseFromJson(Map<String, dynamic> json) =>
    _TeamRoleResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      permissions:
          (json['permissions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
    );

Map<String, dynamic> _$TeamRoleResponseToJson(_TeamRoleResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'permissions': instance.permissions,
    };
