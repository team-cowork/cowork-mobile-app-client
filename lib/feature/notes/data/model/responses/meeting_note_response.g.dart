// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_note_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeetingNoteResponse _$MeetingNoteResponseFromJson(Map<String, dynamic> json) =>
    _MeetingNoteResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      channelId: (json['channelId'] as num?)?.toInt() ?? 0,
      templateId: (json['templateId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      sections: json['content'] == null
          ? const {}
          : parseNoteContent(json['content']),
      createdBy: (json['createdBy'] as num?)?.toInt() ?? 0,
      createdAt: _createdAtOf(json['createdAt'] as String?),
    );

Map<String, dynamic> _$MeetingNoteResponseToJson(
  _MeetingNoteResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'templateId': instance.templateId,
  'title': instance.title,
  'content': instance.sections,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
};
