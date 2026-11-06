// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_message_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchMessageItemResponse _$SearchMessageItemResponseFromJson(
  Map<String, dynamic> json,
) => _SearchMessageItemResponse(
  messageId: json['messageId'] as String,
  channelId: (json['channelId'] as num).toInt(),
  authorId: (json['authorId'] as num?)?.toInt(),
  content: json['content'] as String? ?? '',
  highlight:
      (json['highlight'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  type: json['type'] as String? ?? 'TEXT',
  hasAttachments: json['hasAttachments'] as bool? ?? false,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$SearchMessageItemResponseToJson(
  _SearchMessageItemResponse instance,
) => <String, dynamic>{
  'messageId': instance.messageId,
  'channelId': instance.channelId,
  'authorId': instance.authorId,
  'content': instance.content,
  'highlight': instance.highlight,
  'type': instance.type,
  'hasAttachments': instance.hasAttachments,
  'createdAt': instance.createdAt,
};
