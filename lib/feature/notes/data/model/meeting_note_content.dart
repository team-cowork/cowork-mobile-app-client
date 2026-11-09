import 'dart:convert';

/// 회의록 `content` 와 앱의 섹션 맵(섹션 제목 → 내용) 사이 변환.
///
/// 서버는 본문을 섹션 제목 → 내용 JSON 문자열 하나로 들고 있다. 섹션 제목은
/// 템플릿이 정하므로 여기서는 풀고 묶기만 한다.

/// 요청에 실을 `content`. 섹션 맵을 JSON 문자열로 묶는다.
String encodeNoteContent(Map<String, String> sections) => jsonEncode(sections);

/// 응답의 `content` 를 섹션 맵으로 푼다.
///
/// 문서상 JSON 문자열이지만 객체로 내려오는 경우도 그대로 받는다. JSON 이
/// 아니면 통째로 한 섹션으로 본다. 회의록을 못 여는 것보다 낫다.
Map<String, String> parseNoteContent(Object? raw) {
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

Object? _tryDecode(String body) {
  try {
    return jsonDecode(body);
  } catch (_) {
    return body;
  }
}
