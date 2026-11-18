// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectResponse _$ProjectResponseFromJson(Map<String, dynamic> json) =>
    _ProjectResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$ProjectResponseToJson(_ProjectResponse instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
