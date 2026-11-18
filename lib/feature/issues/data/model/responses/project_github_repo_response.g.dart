// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_github_repo_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectGithubRepoResponse _$ProjectGithubRepoResponseFromJson(
  Map<String, dynamic> json,
) => _ProjectGithubRepoResponse(
  id: (json['id'] as num).toInt(),
  githubRepoUrl: json['githubRepoUrl'] as String? ?? '',
);

Map<String, dynamic> _$ProjectGithubRepoResponseToJson(
  _ProjectGithubRepoResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'githubRepoUrl': instance.githubRepoUrl,
};
