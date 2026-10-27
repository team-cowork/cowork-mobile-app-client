import 'package:freezed_annotation/freezed_annotation.dart';

import 'attachment_response.dart';

part 'message_response.freezed.dart';
part 'message_response.g.dart';

/// 채널 메시지 하나. 목록 조회 응답과 소켓 `message` 이벤트 payload 가 같은 꼴이다.
///
/// 소켓 payload 를 읽다 타입이 틀려도 스트림이 끊기지 않게 `checked` 로 만들어
/// [CheckedFromJsonException] 만 골라 무시할 수 있게 한다. 화면에서 쓰는 필드만 옮긴다.
@freezed
abstract class MessageResponse with _$MessageResponse {
  const MessageResponse._();

  @JsonSerializable(checked: true)
  const factory MessageResponse({
    /// MongoDB ObjectId.
    @JsonKey(name: '_id') required String id,
    required int channelId,
    required int authorId,
    @Default('') String content,

    /// `TEXT` / `FILE` / `SYSTEM`. 시스템 메시지는 사람이 쓴 게 아니다.
    @Default('TEXT') String type,

    /// 붙은 파일. `FILE` 메시지는 [content] 가 비어 있을 수 있다.
    @Default([]) List<AttachmentResponse> attachments,
    required DateTime createdAt,

    /// 스레드 답글이면 부모 메시지 id. 최상위 메시지는 null.
    String? parentMessageId,

    /// 보낸 쪽이 붙인 멱등성 키. 내가 보낸 메시지를 맞춰 볼 때 쓴다.
    String? clientMessageId,
  }) = _MessageResponse;

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);

  bool get isSystem => type == 'SYSTEM';
}
