// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_label_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GithubLabelResponse _$GithubLabelResponseFromJson(Map<String, dynamic> json) =>
    _GithubLabelResponse(
      name: json['name'] as String,
      color: json['color'] as String? ?? '',
    );

Map<String, dynamic> _$GithubLabelResponseToJson(
  _GithubLabelResponse instance,
) => <String, dynamic>{'name': instance.name, 'color': instance.color};
