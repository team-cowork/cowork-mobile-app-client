import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_display_name_response.freezed.dart';
part 'user_display_name_response.g.dart';

/// `GET /users/batch` 응답의 사용자 하나. 작성자·멤버 이름을 채울 때 쓴다.
@freezed
abstract class UserDisplayNameResponse with _$UserDisplayNameResponse {
  const UserDisplayNameResponse._();

  const factory UserDisplayNameResponse({
    required int id,
    @Default('') String name,
    String? nickname,
  }) = _UserDisplayNameResponse;

  factory UserDisplayNameResponse.fromJson(Map<String, dynamic> json) =>
      _$UserDisplayNameResponseFromJson(json);

  /// 화면에 보일 이름. `name` 을 먼저 쓰고, 비어 있으면 `nickname`. 채팅·스레드·DM·멤버
  /// 목록이 같은 규칙을 쓰도록 한곳에 둔다.
  String get displayName => name.isNotEmpty ? name : (nickname ?? '');
}
