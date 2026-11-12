import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_message_request.freezed.dart';
part 'send_message_request.g.dart';

/// `POST /chat/channels/{channelId}/messages` 요청 본문.
///
/// 전송은 서버가 큐에 넣고 바로 돌려주므로, 실제 메시지는 소켓 `message` 이벤트로
/// 온다. [clientMessageId] 로 먼저 보여 준 메시지와 그 이벤트를 짝짓는다.
///
/// [parentMessageId] 를 주면 그 메시지의 스레드 답글로 저장된다.
@Freezed(fromJson: false, toJson: true)
abstract class SendMessageRequest with _$SendMessageRequest {
  @JsonSerializable(includeIfNull: false, createFactory: false)
  const factory SendMessageRequest({
    required String content,
    required String clientMessageId,
    String? parentMessageId,
  }) = _SendMessageRequest;
}
