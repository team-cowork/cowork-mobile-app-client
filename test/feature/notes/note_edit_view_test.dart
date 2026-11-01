import 'package:cowork_app/feature/notes/domain/note.dart';
import 'package:cowork_app/feature/notes/presentation/views/note_edit_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notes_test_server.dart';

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

  group('템플릿 섹션 편집', () {
    // 기본 800x600 뷰에서는 아래 섹션이 화면 밖이라 폰 크기보다 길게 맞춘다.
    setUp(() {
      final view =
          TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view.physicalSize = const Size(400, 1400);
      view.devicePixelRatio = 1;
      addTearDown(view.reset);
    });

    Note noteOf({
      int templateId = 5,
      Map<String, String> sections = const {},
    }) => Note(
      id: 1,
      channelId: 10,
      templateId: templateId,
      title: '주간 회의',
      tags: const [],
      author: const NoteAuthor(
        authorId: 1,
        name: '김준혁',
        initial: '김',
        date: '03.12',
      ),
      sections: sections,
    );

    testWidgets('템플릿 섹션 순서로 칸을 그리고, 템플릿에 없는 본문 섹션은 뒤에 남긴다', (tester) async {
      await tester.pumpWidget(
        notesTestApp(
          NoteEditView(note: noteOf(sections: {'요약': '예전 본문', '안건': '1. 목표'})),
          FakeNotesServer(),
        ),
      );
      await tester.pumpAndSettle();

      final titles = ['참석자', '안건', '결정 사항', '액션 아이템', '다음 회의', '요약'];
      final tops = [for (final t in titles) tester.getTopLeft(find.text(t)).dy];
      expect(tops, orderedEquals([...tops]..sort()));

      expect(find.text('필수'), findsNWidgets(2));
      expect(find.text('템플릿에 없는 섹션'), findsOneWidget);
      // 본문이 있는 칸은 채워 두고, 빈 칸은 템플릿의 안내 문구를 보여준다.
      expect(find.text('예전 본문'), findsOneWidget);
      expect(find.text('1. 목표'), findsOneWidget);
      // 메타 줄은 템플릿 이름을 보여준다.
      expect(find.textContaining('·  주간 회의'), findsOneWidget);
      // 날짜 형식 칸에는 달력 버튼이 있다.
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    });

    testWidgets('필수 섹션이 비어 있으면 저장하지 않고 알린다', (tester) async {
      final server = FakeNotesServer();
      await tester.pumpWidget(
        notesTestApp(NoteEditView(note: noteOf()), server),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(find.text('필수 섹션을 채워 주세요: 참석자, 안건'), findsOneWidget);
      expect(server.requests.where((r) => r.$1 == 'PATCH'), isEmpty);
    });

    testWidgets('템플릿을 못 읽으면 저장된 섹션만으로 연다', (tester) async {
      await tester.pumpWidget(
        notesTestApp(
          NoteEditView(
            note: noteOf(templateId: 999, sections: {'요약': '예전 본문'}),
          ),
          FakeNotesServer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('템플릿을 불러오지 못해 저장된 섹션만 보여요.'), findsOneWidget);
      expect(find.text('요약'), findsOneWidget);
      expect(find.text('참석자'), findsNothing);
      // 무엇이 템플릿 밖인지 모르므로 표시하지 않는다.
      expect(find.text('템플릿에 없는 섹션'), findsNothing);
    });
  });
}
