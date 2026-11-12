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
  return {for (final e in decoded.entries) '${e.key}': _textOf(e.value)};
}

/// 섹션 값 하나를 입력 칸에 넣을 글로.
///
/// 다른 클라이언트가 배열·객체(예: 참석자 목록)를 저장했을 수 있다. Dart 의
/// `toString`(`[a, b]`, `{k: v}`)으로 바꾸면 저장할 때 그 모양이 서버에 덮어써져
/// 원래 값을 되살릴 수 없으므로, JSON 모양 그대로 둔다.
String _textOf(Object? value) => switch (value) {
  null => '',
  String s => s,
  num() || bool() => '$value',
  _ => jsonEncode(value),
};

Object? _tryDecode(String body) {
  try {
    return jsonDecode(body);
  } catch (_) {
    return body;
  }
}
