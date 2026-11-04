import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_message_item_response.freezed.dart';
part 'search_message_item_response.g.dart';

/// `GET /chat/search/messages` 응답의 메시지 하나.
///
/// 웹훅 작성자(`webhook`), 고정 여부(`isPinned`)는 화면이 쓰지 않아 옮기지 않는다.
@freezed
abstract class SearchMessageItemResponse with _$SearchMessageItemResponse {
  const factory SearchMessageItemResponse({
    /// 없으면 fromJson 이 던진다.
    required String messageId,
    required int channelId,

    /// 시스템·웹훅 메시지면 null.
    int? authorId,
    @Default('') String content,

    /// 검색어를 `<em>키워드</em>` 로 감싼 본문 조각들.
    @Default([]) List<String> highlight,

    /// `TEXT` / `FILE` / `SYSTEM`.
    @Default('TEXT') String type,
    @Default(false) bool hasAttachments,

    /// ISO8601.
    required String createdAt,
  }) = _SearchMessageItemResponse;

  factory SearchMessageItemResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchMessageItemResponseFromJson(json);
}
