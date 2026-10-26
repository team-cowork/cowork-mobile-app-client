// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageResponse _$MessageResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_MessageResponse', json, ($checkedConvert) {
  final val = _MessageResponse(
    id: $checkedConvert('_id', (v) => v as String),
    channelId: $checkedConvert('channelId', (v) => (v as num).toInt()),
    authorId: $checkedConvert('authorId', (v) => (v as num).toInt()),
    content: $checkedConvert('content', (v) => v as String? ?? ''),
    type: $checkedConvert('type', (v) => v as String? ?? 'TEXT'),
    attachments: $checkedConvert(
      'attachments',
      (v) =>
          (v as List<dynamic>?)
              ?.map(
                (e) => AttachmentResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    parentMessageId: $checkedConvert('parentMessageId', (v) => v as String?),
    clientMessageId: $checkedConvert('clientMessageId', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'id': '_id'});

Map<String, dynamic> _$MessageResponseToJson(_MessageResponse instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'channelId': instance.channelId,
      'authorId': instance.authorId,
      'content': instance.content,
      'type': instance.type,
      'attachments': instance.attachments,
      'createdAt': instance.createdAt.toIso8601String(),
      'parentMessageId': instance.parentMessageId,
      'clientMessageId': instance.clientMessageId,
    };
