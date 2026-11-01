import 'dart:convert';

import 'package:cowork_app/feature/notes/presentation/widgets/note_choice_chip.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notes_test_server.dart';

void main() {
  // 기본 800x600 뷰에서는 시트 하단 CTA가 화면 밖이라 폰 크기로 맞춘다.
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(400, 900);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  Future<void> openSheet(WidgetTester tester, FakeNotesServer server) async {
    await tester.pumpWidget(notesRouterTestApp(notesTestRouter(), server));
    await tester.pumpAndSettle();
    await tester.tap(find.text('새 노트').last);
    await tester.pumpAndSettle();
  }

  CoworkOptionCard cardOf(WidgetTester tester, String label) =>
      tester.widget(find.widgetWithText(CoworkOptionCard, label));

  CoworkButton createButton(WidgetTester tester) =>
      tester.widget(find.widgetWithText(CoworkButton, '노트 만들기'));

  testWidgets('회의록 채널과 그 채널의 서버 템플릿을 보여주고 기본 템플릿을 먼저 고른다', (tester) async {
    await openSheet(tester, FakeNotesServer());

    // 회의록 채널만 칩으로 나온다. 첫 채널을 고른 상태다.
    expect(find.text('# 회의록'), findsOneWidget);
    expect(find.text('# 주간 회의'), findsOneWidget);
    expect(find.text('# 일반'), findsNothing);
    expect(
      tester
          .widget<NoteChoiceChip>(find.widgetWithText(NoteChoiceChip, '# 회의록'))
          .selected,
      isTrue,
    );

    // 고정 목록이 아니라 서버 템플릿이고, 기본 템플릿이 먼저 골라져 있다.
    expect(find.text('자유 양식'), findsNothing);
    expect(cardOf(tester, '주간 회의').selected, isTrue);
    expect(cardOf(tester, '스프린트 회고').selected, isFalse);
    expect(find.text('기본'), findsOneWidget);
    expect(find.text('Keep · Problem · Try'), findsOneWidget);

    await tester.tap(find.text('스프린트 회고'));
    await tester.pumpAndSettle();

    expect(cardOf(tester, '주간 회의').selected, isFalse);
    expect(cardOf(tester, '스프린트 회고').selected, isTrue);
  });

  testWidgets('템플릿이 없는 채널을 고르면 입력 전에 알리고 노트를 만들 수 없다', (tester) async {
    await openSheet(tester, FakeNotesServer());

    await tester.tap(find.text('# 주간 회의'));
    await tester.pumpAndSettle();

    expect(find.text('이 채널에는 템플릿이 없어요'), findsOneWidget);
    expect(find.widgetWithText(CoworkButton, '템플릿 만들기'), findsOneWidget);
    expect(find.byType(CoworkOptionCard), findsNothing);
    // 제목 칸이 잠겨 있고 CTA 도 비활성이다.
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
      isFalse,
    );
    expect(createButton(tester).enabled, isFalse);
  });

  Iterable<Object> postsOf(FakeNotesServer server) =>
      server.requests.where((request) => request.$1 == 'POST');

  testWidgets('노트 만들기는 서버에 만들지 않고 고른 템플릿의 섹션으로 편집 화면을 연다', (tester) async {
    final server = FakeNotesServer();
    await openSheet(tester, server);

    // 제목이 비면 CTA 비활성.
    expect(createButton(tester).enabled, isFalse);
    await tester.enterText(find.byType(TextFormField), '주간 스크럼');
    await tester.pumpAndSettle();
    expect(createButton(tester).enabled, isTrue);

    await tester.tap(find.widgetWithText(CoworkButton, '노트 만들기'));
    await tester.pumpAndSettle();

    // 회의록은 편집 화면에서 저장할 때 만든다.
    expect(postsOf(server), isEmpty);

    // 편집 화면이 고른 제목과 기본 템플릿(5)의 섹션을 순서대로 그린다.
    expect(find.widgetWithText(CoworkButton, '저장'), findsOneWidget);
    expect(find.text('주간 스크럼'), findsOneWidget);
    for (final title in ['참석자', '안건', '결정 사항', '액션 아이템', '다음 회의']) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('필수'), findsNWidgets(2));

    // 저장하지 않고 나가면 빈 회의록이 남지 않는다.
    await tester.tap(find.byIcon(AppIcon.back));
    await tester.pumpAndSettle();
    expect(postsOf(server), isEmpty);
    expect(server.notes, hasLength(3));
    expect(find.text('회의록을 만들었어요.'), findsNothing);
  });

  testWidgets('저장하면 그때 본문까지 채워 만들고, 실패하면 편집 화면에 입력값을 남긴다', (tester) async {
    final server = FakeNotesServer()..failCreate = (403, '채널 멤버만 작성할 수 있습니다.');
    await openSheet(tester, server);
    await tester.enterText(find.byType(TextFormField), '주간 스크럼');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CoworkButton, '노트 만들기'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, '이름을 쉼표로 구분해 적어 주세요'),
      '김준혁, 도윤',
    );
    await tester.enterText(
      find.widgetWithText(TextField, '논의할 주제를 입력하세요'),
      '배포 일정',
    );
    final save = find.widgetWithText(CoworkButton, '저장');
    await tester.tap(save);
    await tester.pumpAndSettle();

    // 실패하면 편집 화면에 남아 사유를 알리고, 서버에는 아무것도 없다.
    expect(find.text('(403) 채널 멤버만 작성할 수 있습니다.'), findsOneWidget);
    expect(find.text('배포 일정'), findsOneWidget);
    expect(server.notes, hasLength(3));
    // 실패 알림이 사라진 뒤 다시 저장한다.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    server.failCreate = null;
    await tester.tap(save);
    await tester.pumpAndSettle();

    // 만들어지면 목록으로 돌아가 알리고 다시 읽는다.
    expect(find.text('회의록을 만들었어요.'), findsOneWidget);
    expect(find.text('주간 스크럼'), findsOneWidget);
    final created = server.notes.first;
    expect(created['channelId'], 10);
    expect(created['templateId'], 5);
    expect(jsonDecode(created['content'] as String), {
      '참석자': '김준혁, 도윤',
      '안건': '배포 일정',
    });
  });

  testWidgets('템플릿 만들기로 관리 화면에서 템플릿을 만들고 돌아오면 시트가 그 템플릿을 고른다', (tester) async {
    final server = FakeNotesServer();
    await openSheet(tester, server);
    await tester.tap(find.text('# 주간 회의'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CoworkButton, '템플릿 만들기'));
    await tester.pumpAndSettle();

    // 시트가 고른 채널로 관리 화면이 열린다.
    expect(find.text('회의록 템플릿'), findsOneWidget);
    expect(find.text('템플릿이 없어요'), findsOneWidget);

    await tester.tap(find.widgetWithText(CoworkButton, '새 템플릿'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '1:1 미팅');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CoworkButton, '템플릿 만들기'));
    await tester.pumpAndSettle();

    // 만든 템플릿의 편집 화면에서 관리 화면, 다시 시트로 돌아간다.
    expect(find.text('템플릿 편집'), findsOneWidget);
    await tester.tap(find.byIcon(AppIcon.back));
    await tester.pumpAndSettle();
    expect(find.text('1:1 미팅'), findsOneWidget);
    await tester.tap(find.byIcon(AppIcon.back));
    await tester.pumpAndSettle();

    expect(server.templates[11]!.map((t) => t['name']), ['1:1 미팅']);
    expect(find.text('이 채널에는 템플릿이 없어요'), findsNothing);
    expect(cardOf(tester, '1:1 미팅').selected, isTrue);
  });
}
