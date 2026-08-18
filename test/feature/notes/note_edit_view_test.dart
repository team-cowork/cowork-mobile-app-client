import 'package:cowork_app/feature/notes/presentation/views/note_edit_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('applyMarkdown', () {
    test('굵게: 선택 텍스트를 **로 감싼다', () {
      final r = applyMarkdown(
        '회의 안건',
        const TextSelection(baseOffset: 0, extentOffset: 2),
        MarkdownAction.bold,
      );
      expect(r.text, '**회의** 안건');
      expect(r.selection.baseOffset, 6);
    });

    test('굵게: 선택이 없으면 커서 자리에 ****를 넣고 가운데로 이동', () {
      final r = applyMarkdown(
        'ab',
        const TextSelection.collapsed(offset: 1),
        MarkdownAction.bold,
      );
      expect(r.text, 'a****b');
      expect(r.selection.baseOffset, 3);
    });

    test('헤딩: 현재 줄 맨 앞에 "# "를 삽입', () {
      final r = applyMarkdown(
        '첫째 줄\n둘째 줄',
        const TextSelection.collapsed(offset: 6), // 둘째 줄 안
        MarkdownAction.heading,
      );
      expect(r.text, '첫째 줄\n# 둘째 줄');
    });

    test('불릿: 현재 줄 맨 앞에 "- "를 삽입', () {
      final r = applyMarkdown(
        '항목',
        const TextSelection.collapsed(offset: 0),
        MarkdownAction.bullet,
      );
      expect(r.text, '- 항목');
    });

    test('체크박스: 줄 맨 앞에 "- [ ] "를 삽입', () {
      final r = applyMarkdown(
        '할일',
        const TextSelection.collapsed(offset: 2),
        MarkdownAction.checkbox,
      );
      expect(r.text, '- [ ] 할일');
    });

    test('멘션: 커서 자리에 @를 삽입', () {
      final r = applyMarkdown(
        'hi ',
        const TextSelection.collapsed(offset: 3),
        MarkdownAction.mention,
      );
      expect(r.text, 'hi @');
      expect(r.selection.baseOffset, 4);
    });

    test('유효하지 않은 선택(-1)은 문서 끝으로 취급', () {
      final r = applyMarkdown(
        'end',
        const TextSelection.collapsed(offset: -1),
        MarkdownAction.mention,
      );
      expect(r.text, 'end@');
    });
  });

  group('parseActionItems', () {
    test('체크 여부에 따라 done을 채운다', () {
      final items = parseActionItems('- [x] 완료함\n- [ ] 안함');
      expect(items.length, 2);
      expect(items[0].label, '완료함');
      expect(items[0].done, isTrue);
      expect(items[1].label, '안함');
      expect(items[1].done, isFalse);
    });

    test('체크박스 문법이 아닌 줄도 미완료 항목으로', () {
      final items = parseActionItems('그냥 할일\n- 불릿 할일');
      expect(items.length, 2);
      expect(items[0].label, '그냥 할일');
      expect(items[0].done, isFalse);
      expect(items[1].label, '불릿 할일');
    });

    test('빈 줄은 건너뛴다', () {
      final items = parseActionItems('- [ ] a\n\n   \n- [x] b');
      expect(items.length, 2);
    });
  });
}
