// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_comment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GithubCommentResponse _$GithubCommentResponseFromJson(
  Map<String, dynamic> json,
) => _GithubCommentResponse(
  id: (json['id'] as num).toInt(),
  author: json['author'] as String? ?? '',
  body: json['body'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$GithubCommentResponseToJson(
  _GithubCommentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'author': instance.author,
  'body': instance.body,
  'createdAt': instance.createdAt.toIso8601String(),
};
