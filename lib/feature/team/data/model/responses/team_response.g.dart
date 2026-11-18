// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamResponse _$TeamResponseFromJson(Map<String, dynamic> json) =>
    _TeamResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      ownerId: (json['ownerId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TeamResponseToJson(_TeamResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'ownerId': instance.ownerId,
    };
