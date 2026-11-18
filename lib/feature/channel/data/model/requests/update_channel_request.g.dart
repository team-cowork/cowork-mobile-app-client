// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_channel_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateChannelRequest _$UpdateChannelRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateChannelRequest(
  name: json['name'] as String?,
  description: json['description'] as String?,
  isPrivate: json['isPrivate'] as bool?,
  projectId: (json['projectId'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateChannelRequestToJson(
  _UpdateChannelRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'description': ?instance.description,
  'isPrivate': ?instance.isPrivate,
  'projectId': ?instance.projectId,
};
