// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_conversation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DmConversationResponse _$DmConversationResponseFromJson(
  Map<String, dynamic> json,
) => _DmConversationResponse(
  channelId: (json['channelId'] as num).toInt(),
  otherUserId: (json['otherUserId'] as num?)?.toInt(),
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  lastMessage: json['lastMessage'] == null
      ? null
      : DmLastMessageResponse.fromJson(
          json['lastMessage'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DmConversationResponseToJson(
  _DmConversationResponse instance,
) => <String, dynamic>{
  'channelId': instance.channelId,
  'otherUserId': instance.otherUserId,
  'unreadCount': instance.unreadCount,
  'lastMessage': instance.lastMessage,
};
