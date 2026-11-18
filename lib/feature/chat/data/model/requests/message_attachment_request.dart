import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_attachment_request.freezed.dart';
part 'message_attachment_request.g.dart';

/// 메시지에 붙일 파일 하나. `POST /chat/channels/{channelId}/messages` 의 `attachments`.
@Freezed(fromJson: false, toJson: true)
abstract class MessageAttachmentRequest with _$MessageAttachmentRequest {
  const factory MessageAttachmentRequest({
    /// 업로드 확인(`files/confirm`)이 돌려준 확정 키.
    required String objectKey,
  }) = _MessageAttachmentRequest;
}
