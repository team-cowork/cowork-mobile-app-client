import 'dart:convert';

/// `/channels/{channelId}/meeting-notes` 응답 본문.
///
/// 게이트웨이 envelope 을 벗긴 `data` 를 받는다(`unwrapPayload`).
///
/// 서버는 본문을 섹션 이름 → 내용 JSON 문자열 하나로 들고 있다. 회의록 화면이
/// 쓰는 안건·결정 사항 같은 구분은 여기서 [sections] 로만 풀어 두고, 어느 섹션이
/// 어느 화면 항목인지는 [Note.fromMeetingNote] 가 정한다.
class MeetingNoteResponse {
  const MeetingNoteResponse({
    required this.id,
    required this.channelId,
    required this.title,
    required this.sections,
    required this.createdBy,
    required this.createdAt,
  });

  factory MeetingNoteResponse.fromJson(Map<String, dynamic> json) =>
      MeetingNoteResponse(
        id: json['id'] as int? ?? 0,
        channelId: json['channelId'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        sections: parseSections(json['content']),
        createdBy: json['createdBy'] as int? ?? 0,
        // 정렬에만 쓰므로 못 읽으면 맨 뒤로 보낸다.
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  final int id;

  /// 회의록이 속한 채널. 수정·삭제 경로에 필요해 같이 들고 다닌다.
  final int channelId;

  final String title;

  /// 섹션 이름 → 내용. 예: `{'안건': '1. ...', '결정 사항': '· ...'}`.
  final Map<String, String> sections;

  /// 작성자 사용자 id. 이름·사진은 `/users/{id}` 에서 따로 읽는다.
  final int createdBy;

  final DateTime createdAt;

  /// `content` 를 섹션 맵으로 푼다.
  ///
  /// 문서상 JSON 문자열이지만 객체로 내려오는 경우도 그대로 받는다. JSON 이
  /// 아니면 통째로 한 섹션으로 본다. 회의록을 못 여는 것보다 낫다.
  static Map<String, String> parseSections(Object? raw) {
    final decoded = switch (raw) {
      String s when s.trim().isEmpty => null,
      String s => _tryDecode(s),
      _ => raw,
    };
    if (decoded is! Map) {
      return decoded == null ? const {} : {'요약': '$decoded'};
    }
    return {for (final e in decoded.entries) '${e.key}': '${e.value}'};
  }

  static Object? _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
