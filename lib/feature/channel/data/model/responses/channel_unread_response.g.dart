// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_unread_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChannelUnreadResponse _$ChannelUnreadResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ChannelUnreadResponse', json, ($checkedConvert) {
  final val = _ChannelUnreadResponse(
    channelId: $checkedConvert('channelId', (v) => (v as num).toInt()),
    unreadCount: $checkedConvert('unreadCount', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$ChannelUnreadResponseToJson(
  _ChannelUnreadResponse instance,
) => <String, dynamic>{
  'channelId': instance.channelId,
  'unreadCount': instance.unreadCount,
};
