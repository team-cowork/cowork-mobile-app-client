import 'package:cowork_app/feature/notes/domain/note.dart';
import 'package:flutter_test/flutter_test.dart';

const _author = NoteAuthor(authorId: 1, name: 'a', initial: 'A', date: '');

Note _note(Map<String, String> sections) => Note(
  id: 1,
  title: '주간 회의',
  tags: const [],
  author: _author,
  sections: sections,
);

void main() {
  test('shareText 는 제목과 내용 있는 섹션을 저장된 순서대로 잇는다', () {
    final note = _note({'안건': ' 1. 일정 ', '결정 사항': '', '액션': '- 문서화'});

    expect(note.shareText, '# 주간 회의\n\n## 안건\n1. 일정\n\n## 액션\n- 문서화');
  });

  test('shareText 는 섹션이 없으면 제목만 낸다', () {
    expect(_note(const {}).shareText, '# 주간 회의');
  });
}
