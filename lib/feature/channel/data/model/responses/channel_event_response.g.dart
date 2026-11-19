// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_event_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChannelEventResponse _$ChannelEventResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ChannelEventResponse', json, ($checkedConvert) {
  final val = _ChannelEventResponse(
    channelId: $checkedConvert('channelId', (v) => (v as num?)?.toInt()),
    teamId: $checkedConvert('teamId', (v) => (v as num?)?.toInt()),
    name: $checkedConvert('name', (v) => v as String?),
    viewType: $checkedConvert('viewType', (v) => v as String?),
    projectId: $checkedConvert('projectId', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$ChannelEventResponseToJson(
  _ChannelEventResponse instance,
) => <String, dynamic>{
  'channelId': instance.channelId,
  'teamId': instance.teamId,
  'name': instance.name,
  'viewType': instance.viewType,
  'projectId': instance.projectId,
};
