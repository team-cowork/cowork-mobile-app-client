import 'dart:convert';

/// `POST /channels/{channelId}/meeting-notes` 요청 본문.
///
/// 편집 화면에서 처음 저장할 때 보낸다. 그래서 본문까지 채워서 만든다.
class CreateMeetingNoteRequest {
  const CreateMeetingNoteRequest({
    required this.templateId,
    required this.title,
    required this.sections,
  });

  final int templateId;
  final String title;

  /// 섹션 제목 → 내용.
  final Map<String, String> sections;

  Map<String, dynamic> toJson() => {
    'templateId': templateId,
    'title': title,
    'content': jsonEncode(sections),
  };
}

/// `PATCH /channels/{channelId}/meeting-notes/{noteId}` 요청 본문.
class UpdateMeetingNoteRequest {
  const UpdateMeetingNoteRequest({required this.title, required this.sections});

  final String title;

  /// 섹션 제목 → 내용. 서버는 이 순서를 지키지 않는다(`NotesRepository.fetchNotes`).
  final Map<String, String> sections;

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': jsonEncode(sections),
  };
}
