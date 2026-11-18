// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThreadResponse _$ThreadResponseFromJson(Map<String, dynamic> json) =>
    _ThreadResponse(
      id: (json['id'] as num).toInt(),
      channelId: (json['channelId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      parentMessageId: json['parentMessageId'] as String,
      isArchived: json['isArchived'] as bool? ?? false,
    );

Map<String, dynamic> _$ThreadResponseToJson(_ThreadResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'name': instance.name,
      'parentMessageId': instance.parentMessageId,
      'isArchived': instance.isArchived,
    };
