import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting_note_attachment_response.freezed.dart';
part 'meeting_note_attachment_response.g.dart';

/// 회의록 응답의 `attachments` 항목 하나. 서버는 키와 이름만 준다.
@freezed
abstract class MeetingNoteAttachmentResponse
    with _$MeetingNoteAttachmentResponse {
  const factory MeetingNoteAttachmentResponse({
    @Default('') String objectKey,
    @Default('') String name,
  }) = _MeetingNoteAttachmentResponse;

  factory MeetingNoteAttachmentResponse.fromJson(Map<String, dynamic> json) =>
      _$MeetingNoteAttachmentResponseFromJson(json);
}
