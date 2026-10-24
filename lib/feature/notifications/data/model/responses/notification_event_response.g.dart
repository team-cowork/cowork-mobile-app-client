// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_event_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationEventResponse _$NotificationEventResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_NotificationEventResponse', json, ($checkedConvert) {
  final val = _NotificationEventResponse(
    type: $checkedConvert('type', (v) => v as String? ?? ''),
    title: $checkedConvert('title', (v) => v as String? ?? ''),
    body: $checkedConvert('body', (v) => v as String? ?? ''),
    channelId: $checkedConvert('channelId', (v) => (v as num?)?.toInt() ?? 0),
    teamId: $checkedConvert('teamId', (v) => (v as num?)?.toInt() ?? 0),
  );
  return val;
});

Map<String, dynamic> _$NotificationEventResponseToJson(
  _NotificationEventResponse instance,
) => <String, dynamic>{
  'type': instance.type,
  'title': instance.title,
  'body': instance.body,
  'channelId': instance.channelId,
  'teamId': instance.teamId,
};
