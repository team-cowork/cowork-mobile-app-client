import 'package:freezed_annotation/freezed_annotation.dart';

import '../meeting_note_content.dart';
import 'meeting_note_attachment_request.dart';

part 'update_meeting_note_request.freezed.dart';
part 'update_meeting_note_request.g.dart';

/// `PATCH /channels/{channelId}/meeting-notes/{noteId}` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class UpdateMeetingNoteRequest with _$UpdateMeetingNoteRequest {
  // 첨부 항목도 Map 으로 펼쳐야 toJson 결과를 그대로 검사할 수 있다.
  @JsonSerializable(explicitToJson: true, createFactory: false)
  const factory UpdateMeetingNoteRequest({
    required String title,

    /// 섹션 제목 → 내용. 서버에는 JSON 문자열 `content` 로 간다.
    @JsonKey(name: 'content', toJson: encodeNoteContent)
    required Map<String, String> sections,

    /// 첨부 전체 목록. 서버는 이 목록으로 통째로 바꾼다(빈 배열이면 모두 해제).
    /// 편집 화면이 언제나 전체 목록을 들고 있으므로 생략(=유지)은 쓰지 않는다.
    required List<MeetingNoteAttachmentRequest> attachments,
  }) = _UpdateMeetingNoteRequest;
}
