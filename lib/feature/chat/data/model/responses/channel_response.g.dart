// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChannelResponse _$ChannelResponseFromJson(Map<String, dynamic> json) =>
    _ChannelResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      viewType: json['viewType'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ChannelResponseToJson(_ChannelResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'viewType': instance.viewType,
      'description': instance.description,
    };
