import 'package:freezed_annotation/freezed_annotation.dart';

import '../meeting_note_content.dart';
import 'meeting_note_attachment_request.dart';

part 'create_meeting_note_request.freezed.dart';
part 'create_meeting_note_request.g.dart';

/// `POST /channels/{channelId}/meeting-notes` 요청 본문.
///
/// 편집 화면에서 처음 저장할 때 보낸다. 그래서 본문까지 채워서 만든다.
@Freezed(fromJson: false, toJson: true)
abstract class CreateMeetingNoteRequest with _$CreateMeetingNoteRequest {
  // 첨부 항목도 Map 으로 펼쳐야 toJson 결과를 그대로 검사할 수 있다.
  @JsonSerializable(explicitToJson: true, createFactory: false)
  const factory CreateMeetingNoteRequest({
    required int templateId,
    required String title,

    /// 섹션 제목 → 내용. 서버에는 JSON 문자열 `content` 로 간다.
    @JsonKey(name: 'content', toJson: encodeNoteContent)
    required Map<String, String> sections,

    /// 붙일 파일. 업로드를 확인한 파일만 넣을 수 있다.
    required List<MeetingNoteAttachmentRequest> attachments,
  }) = _CreateMeetingNoteRequest;
}
