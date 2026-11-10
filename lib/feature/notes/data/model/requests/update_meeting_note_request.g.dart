// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_meeting_note_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$UpdateMeetingNoteRequestToJson(
  _UpdateMeetingNoteRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'content': encodeNoteContent(instance.sections),
};
