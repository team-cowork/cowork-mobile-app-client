// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_last_message_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DmLastMessageResponse _$DmLastMessageResponseFromJson(
  Map<String, dynamic> json,
) => _DmLastMessageResponse(
  authorId: (json['authorId'] as num?)?.toInt(),
  content: json['content'] as String? ?? '',
  type: json['type'] as String? ?? 'TEXT',
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DmLastMessageResponseToJson(
  _DmLastMessageResponse instance,
) => <String, dynamic>{
  'authorId': instance.authorId,
  'content': instance.content,
  'type': instance.type,
  'createdAt': instance.createdAt.toIso8601String(),
};
