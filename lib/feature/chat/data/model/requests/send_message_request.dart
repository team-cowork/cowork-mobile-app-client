import 'package:freezed_annotation/freezed_annotation.dart';

import 'message_attachment_request.dart';

part 'send_message_request.freezed.dart';
part 'send_message_request.g.dart';

/// `POST /chat/channels/{channelId}/messages` 요청 본문.
///
/// 전송은 서버가 큐에 넣고 바로 돌려주므로, 실제 메시지는 소켓 `message` 이벤트로
/// 온다. [clientMessageId] 로 먼저 보여 준 메시지와 그 이벤트를 짝짓는다.
///
/// [parentMessageId] 를 주면 그 메시지의 스레드 답글로 저장된다.
///
/// 파일을 보낼 때는 [type] 을 `FILE` 로 하고 [attachments] 에 확정 키를 싣는다. 이때
/// [content] 는 비어도 된다. 서버는 첨부 메시지를 [clientMessageId] 로 한 번만 저장하므로,
/// 같은 값으로 다시 보내도 두 번 저장되지 않는다.
@Freezed(fromJson: false, toJson: true)
abstract class SendMessageRequest with _$SendMessageRequest {
  @JsonSerializable(
    includeIfNull: false,
    explicitToJson: true,
    createFactory: false,
  )
  const factory SendMessageRequest({
    required String content,
    required String clientMessageId,
    String? parentMessageId,

    /// `TEXT`(생략 시) 또는 `FILE`.
    String? type,
    List<MessageAttachmentRequest>? attachments,
  }) = _SendMessageRequest;
}
