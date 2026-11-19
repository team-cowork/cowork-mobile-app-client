// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook_author_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WebhookAuthorResponse _$WebhookAuthorResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_WebhookAuthorResponse', json, ($checkedConvert) {
  final val = _WebhookAuthorResponse(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    name: $checkedConvert('name', (v) => v as String? ?? ''),
    avatarUrl: $checkedConvert('avatarUrl', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$WebhookAuthorResponseToJson(
  _WebhookAuthorResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
};
