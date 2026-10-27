// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presigned_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PresignedUploadResponse _$PresignedUploadResponseFromJson(
  Map<String, dynamic> json,
) => _PresignedUploadResponse(
  objectKey: json['object_key'] as String? ?? '',
  uploadUrl: json['upload_url'] as String? ?? '',
);

Map<String, dynamic> _$PresignedUploadResponseToJson(
  _PresignedUploadResponse instance,
) => <String, dynamic>{
  'object_key': instance.objectKey,
  'upload_url': instance.uploadUrl,
};
