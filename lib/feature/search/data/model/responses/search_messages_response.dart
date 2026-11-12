import 'package:freezed_annotation/freezed_annotation.dart';

import 'search_message_item_response.dart';

part 'search_messages_response.freezed.dart';
part 'search_messages_response.g.dart';

/// `GET /chat/search/messages` 응답 본문. 최신순이다.
@freezed
abstract class SearchMessagesResponse with _$SearchMessagesResponse {
  const factory SearchMessagesResponse({
    @Default([]) List<SearchMessageItemResponse> messages,

    /// 다음 페이지 요청의 `before` 에 그대로 넣는 값. 마지막 페이지면 null.
    String? nextCursor,
  }) = _SearchMessagesResponse;

  factory SearchMessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchMessagesResponseFromJson(json);
}
