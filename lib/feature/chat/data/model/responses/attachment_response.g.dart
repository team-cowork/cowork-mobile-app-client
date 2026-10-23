// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttachmentResponse _$AttachmentResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AttachmentResponse', json, ($checkedConvert) {
      final val = _AttachmentResponse(
        name: $checkedConvert('name', (v) => v as String? ?? ''),
        size: $checkedConvert('size', (v) => (v as num?)?.toInt() ?? 0),
        mimeType: $checkedConvert('mimeType', (v) => v as String? ?? ''),
      );
      return val;
    });

Map<String, dynamic> _$AttachmentResponseToJson(_AttachmentResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'size': instance.size,
      'mimeType': instance.mimeType,
    };
