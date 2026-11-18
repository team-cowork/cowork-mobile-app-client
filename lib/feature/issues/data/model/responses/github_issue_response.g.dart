// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_issue_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GithubIssueResponse _$GithubIssueResponseFromJson(Map<String, dynamic> json) =>
    _GithubIssueResponse(
      number: (json['number'] as num).toInt(),
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      state: json['state'] as String? ?? 'open',
      htmlUrl: json['htmlUrl'] as String? ?? '',
      labels:
          (json['labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$GithubIssueResponseToJson(
  _GithubIssueResponse instance,
) => <String, dynamic>{
  'number': instance.number,
  'title': instance.title,
  'author': instance.author,
  'state': instance.state,
  'htmlUrl': instance.htmlUrl,
  'labels': instance.labels,
  'createdAt': instance.createdAt.toIso8601String(),
};
