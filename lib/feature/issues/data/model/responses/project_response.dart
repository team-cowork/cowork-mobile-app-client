import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_response.freezed.dart';
part 'project_response.g.dart';

/// `GET /project/projects/me` 응답의 프로젝트 하나.
@freezed
abstract class ProjectResponse with _$ProjectResponse {
  const factory ProjectResponse({required int id, @Default('') String name}) =
      _ProjectResponse;

  factory ProjectResponse.fromJson(Map<String, dynamic> json) =>
      _$ProjectResponseFromJson(json);
}
