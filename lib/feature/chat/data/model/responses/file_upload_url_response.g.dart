// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_upload_url_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FileUploadUrlResponse _$FileUploadUrlResponseFromJson(
  Map<String, dynamic> json,
) => _FileUploadUrlResponse(
  objectKey: json['objectKey'] as String? ?? '',
  uploadUrl: json['uploadUrl'] as String? ?? '',
  headers:
      (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$FileUploadUrlResponseToJson(
  _FileUploadUrlResponse instance,
) => <String, dynamic>{
  'objectKey': instance.objectKey,
  'uploadUrl': instance.uploadUrl,
  'headers': instance.headers,
};
