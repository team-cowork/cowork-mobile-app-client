import 'package:freezed_annotation/freezed_annotation.dart';

import '../meeting_note_content.dart';

part 'update_meeting_note_request.freezed.dart';
part 'update_meeting_note_request.g.dart';

/// `PATCH /channels/{channelId}/meeting-notes/{noteId}` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class UpdateMeetingNoteRequest with _$UpdateMeetingNoteRequest {
  const factory UpdateMeetingNoteRequest({
    required String title,

    /// 섹션 제목 → 내용. 서버에는 JSON 문자열 `content` 로 간다.
    @JsonKey(name: 'content', toJson: encodeNoteContent)
    required Map<String, String> sections,
  }) = _UpdateMeetingNoteRequest;
}
