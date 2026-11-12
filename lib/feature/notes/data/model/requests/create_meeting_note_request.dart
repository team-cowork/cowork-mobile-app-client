import 'package:freezed_annotation/freezed_annotation.dart';

import '../meeting_note_content.dart';

part 'create_meeting_note_request.freezed.dart';
part 'create_meeting_note_request.g.dart';

/// `POST /channels/{channelId}/meeting-notes` 요청 본문.
///
/// 편집 화면에서 처음 저장할 때 보낸다. 그래서 본문까지 채워서 만든다.
@Freezed(fromJson: false, toJson: true)
abstract class CreateMeetingNoteRequest with _$CreateMeetingNoteRequest {
  const factory CreateMeetingNoteRequest({
    required int templateId,
    required String title,

    /// 섹션 제목 → 내용. 서버에는 JSON 문자열 `content` 로 간다.
    @JsonKey(name: 'content', toJson: encodeNoteContent)
    required Map<String, String> sections,
  }) = _CreateMeetingNoteRequest;
}
