// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_issue_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateIssueRequest _$CreateIssueRequestFromJson(Map<String, dynamic> json) =>
    _CreateIssueRequest(
      title: json['title'] as String,
      body: json['body'] as String?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$CreateIssueRequestToJson(_CreateIssueRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': ?instance.body,
      'label': ?instance.label,
    };
