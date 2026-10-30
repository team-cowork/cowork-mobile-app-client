// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_section_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TemplateSectionResponse _$TemplateSectionResponseFromJson(
  Map<String, dynamic> json,
) => _TemplateSectionResponse(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String? ?? '',
  type: json['type'] as String?,
  placeholder: json['placeholder'] as String?,
  isRequired: json['isRequired'] as bool? ?? false,
);

Map<String, dynamic> _$TemplateSectionResponseToJson(
  _TemplateSectionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'type': instance.type,
  'placeholder': instance.placeholder,
  'isRequired': instance.isRequired,
};
