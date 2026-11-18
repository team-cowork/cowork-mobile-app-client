import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_label_response.freezed.dart';
part 'github_label_response.g.dart';

/// 저장소에 정의된 라벨 하나. [color] 는 `#` 없는 hex.
@freezed
abstract class GithubLabelResponse with _$GithubLabelResponse {
  const factory GithubLabelResponse({
    required String name,
    @Default('') String color,
  }) = _GithubLabelResponse;

  factory GithubLabelResponse.fromJson(Map<String, dynamic> json) =>
      _$GithubLabelResponseFromJson(json);
}
