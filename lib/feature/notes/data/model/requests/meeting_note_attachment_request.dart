import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting_note_attachment_request.freezed.dart';
part 'meeting_note_attachment_request.g.dart';

/// 회의록 생성·수정 요청의 `attachments` 항목 하나.
@Freezed(fromJson: false, toJson: true)
abstract class MeetingNoteAttachmentRequest
    with _$MeetingNoteAttachmentRequest {
  const factory MeetingNoteAttachmentRequest({
    /// 업로드 확인(`files/confirm`)이 돌려준 확정 키. 업로드 주소를 받을 때의 임시
    /// 키(`chat-uploads/...`)를 보내면 서버가 거절한다.
    required String objectKey,

    /// 받을 때 보일 파일 이름.
    required String name,
  }) = _MeetingNoteAttachmentRequest;
}
