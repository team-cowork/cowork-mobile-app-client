// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamSummaryResponse _$TeamSummaryResponseFromJson(Map<String, dynamic> json) =>
    _TeamSummaryResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$TeamSummaryResponseToJson(
  _TeamSummaryResponse instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};
