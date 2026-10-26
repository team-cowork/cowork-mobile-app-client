import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_display_name_response.freezed.dart';
part 'user_display_name_response.g.dart';

/// `GET /users/batch` 응답의 사용자 하나. 메시지 작성자 이름을 채울 때 쓴다.
@freezed
abstract class UserDisplayNameResponse with _$UserDisplayNameResponse {
  const factory UserDisplayNameResponse({
    required int id,
    @Default('') String name,
    String? nickname,
  }) = _UserDisplayNameResponse;

  factory UserDisplayNameResponse.fromJson(Map<String, dynamic> json) =>
      _$UserDisplayNameResponseFromJson(json);
}
