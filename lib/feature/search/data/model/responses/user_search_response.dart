import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../profile/data/model/responses/user_response.dart';

part 'user_search_response.freezed.dart';
part 'user_search_response.g.dart';

/// `GET /users/search` 응답 본문. 게이트웨이 envelope 을 벗긴 `data` 를 받는다.
///
/// 사용자 하나의 표현은 `/users/me` 와 같아서 [UserResponse] 를 그대로 쓴다.
/// 서버는 `page`, `page_size`, `total_count` 도 주지만 화면이 쓰지 않아 옮기지 않는다.
@freezed
abstract class UserSearchResponse with _$UserSearchResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserSearchResponse({
    @Default([]) List<UserResponse> items,

    /// 다음 페이지가 있는지.
    @Default(false) bool hasNext,
  }) = _UserSearchResponse;

  factory UserSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$UserSearchResponseFromJson(json);
}
