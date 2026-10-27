import 'dart:convert';

import '../domain/note.dart';

/// `POST /channels/{channelId}/meeting-notes` 요청 본문.
class CreateMeetingNoteRequest {
  const CreateMeetingNoteRequest({
    required this.templateId,
    required this.title,
    required this.sections,
  });

  final int templateId;
  final String title;
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
  final Map<String, String> sections;

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': jsonEncode(sections),
  };
}

/// 화면이 다루는 항목을 서버 섹션 맵으로 되돌린다.
///
/// 키는 [Note.fromMeetingNote] 가 읽는 이름과 짝을 맞춘다. 빈 항목은 빼서
/// 서버에 빈 섹션이 쌓이지 않게 한다.
Map<String, String> sectionsOf({
  required String summary,
  List<String> agenda = const [],
  List<String> decisions = const [],
  List<NoteActionItem> actionItems = const [],
}) {
  final sections = {
    '요약': summary,
    '안건': agenda.join('\n'),
    '결정 사항': decisions.join('\n'),
    '액션 아이템': actionItems
        .map((item) => '- [${item.done ? 'x' : ' '}] ${item.label}')
        .join('\n'),
  };
  sections.removeWhere((_, value) => value.trim().isEmpty);
  return sections;
}
