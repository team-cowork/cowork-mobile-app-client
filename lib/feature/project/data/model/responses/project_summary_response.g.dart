// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectSummaryResponse _$ProjectSummaryResponseFromJson(
  Map<String, dynamic> json,
) => _ProjectSummaryResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? '',
);

Map<String, dynamic> _$ProjectSummaryResponseToJson(
  _ProjectSummaryResponse instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};
