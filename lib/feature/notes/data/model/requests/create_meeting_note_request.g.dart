// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_meeting_note_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateMeetingNoteRequestToJson(
  _CreateMeetingNoteRequest instance,
) => <String, dynamic>{
  'templateId': instance.templateId,
  'title': instance.title,
  'content': encodeNoteContent(instance.sections),
};
