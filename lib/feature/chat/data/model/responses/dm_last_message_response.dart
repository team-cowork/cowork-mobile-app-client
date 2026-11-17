import 'package:freezed_annotation/freezed_annotation.dart';

part 'dm_last_message_response.freezed.dart';
part 'dm_last_message_response.g.dart';

/// `GET /chat/dms` 응답에서 대화의 마지막 메시지. 목록 미리보기에만 쓴다.
@freezed
abstract class DmLastMessageResponse with _$DmLastMessageResponse {
  const factory DmLastMessageResponse({
    /// 시스템·웹훅 메시지면 null.
    int? authorId,
    @Default('') String content,

    /// `TEXT` / `FILE` / `SYSTEM`. 파일만 있는 메시지는 [content] 가 비어 있을 수 있다.
    @Default('TEXT') String type,
    required DateTime createdAt,
  }) = _DmLastMessageResponse;

  factory DmLastMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$DmLastMessageResponseFromJson(json);
}
