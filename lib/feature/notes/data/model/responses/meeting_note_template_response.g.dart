// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_note_template_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeetingNoteTemplateResponse _$MeetingNoteTemplateResponseFromJson(
  Map<String, dynamic> json,
) => _MeetingNoteTemplateResponse(
  id: (json['id'] as num).toInt(),
  channelId: (json['channelId'] as num).toInt(),
  name: json['name'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? false,
  sections:
      (json['sections'] as List<dynamic>?)
          ?.map(
            (e) => TemplateSectionResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$MeetingNoteTemplateResponseToJson(
  _MeetingNoteTemplateResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'name': instance.name,
  'isActive': instance.isActive,
  'sections': instance.sections,
};
