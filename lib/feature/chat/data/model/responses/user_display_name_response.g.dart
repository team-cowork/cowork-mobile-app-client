// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_display_name_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDisplayNameResponse _$UserDisplayNameResponseFromJson(
  Map<String, dynamic> json,
) => _UserDisplayNameResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? '',
  nickname: json['nickname'] as String?,
);

Map<String, dynamic> _$UserDisplayNameResponseToJson(
  _UserDisplayNameResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nickname': instance.nickname,
};
