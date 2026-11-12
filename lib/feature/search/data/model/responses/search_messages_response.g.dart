// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_messages_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchMessagesResponse _$SearchMessagesResponseFromJson(
  Map<String, dynamic> json,
) => _SearchMessagesResponse(
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map(
            (e) =>
                SearchMessageItemResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$SearchMessagesResponseToJson(
  _SearchMessagesResponse instance,
) => <String, dynamic>{
  'messages': instance.messages,
  'nextCursor': instance.nextCursor,
};
