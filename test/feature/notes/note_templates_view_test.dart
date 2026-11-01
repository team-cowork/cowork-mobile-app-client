import 'dart:async';

import 'package:cowork_app/feature/notes/presentation/widgets/note_choice_chip.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notes_test_server.dart';

void main() {
  // 시트 CTA·아래쪽 섹션이 기본 800x600 뷰 밖으로 밀리지 않게 폰 크기로 맞춘다.
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(400, 900);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  /// 회의록 탭 → `템플릿` 으로 목록 화면을 연다.
  Future<void> openTemplates(
    WidgetTester tester,
    FakeNotesServer server,
  ) async {
    await tester.pumpWidget(notesRouterTestApp(notesTestRouter(), server));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CoworkButton, '템플릿'));
    await tester.pumpAndSettle();
  }

  /// 목록에서 [name] 템플릿 카드를 눌러 편집 화면을 연다.
  Future<void> openEditor(
    WidgetTester tester,
    FakeNotesServer server,
    String name,
  ) async {
    await openTemplates(tester, server);
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  /// 편집 화면 섹션 행의 삭제 버튼.
  Finder deleteButtonOf(String section) => find.descendant(
    of: find
        .ancestor(of: find.text(section), matching: find.byType(InkWell))
        .first,
    matching: find.byIcon(Icons.delete_outline),
  );

  testWidgets('첫 회의록 채널의 템플릿을 카드로 보여준다', (tester) async {
    await openTemplates(tester, FakeNotesServer());

    expect(find.text('회의록 템플릿'), findsOneWidget);
    expect(
      tester
          .widget<NoteChoiceChip>(find.widgetWithText(NoteChoiceChip, '# 회의록'))
          .selected,
      isTrue,
    );
    expect(find.text('주간 회의'), findsOneWidget);
    expect(find.text('스프린트 회고'), findsOneWidget);
    expect(find.text('기본'), findsOneWidget);
    expect(find.text('섹션 5개 · 필수 2개'), findsOneWidget);
    expect(find.text('섹션 3개'), findsOneWidget);
  });

  testWidgets('채널을 바꾸면 그 채널의 템플릿을 읽는다', (tester) async {
    await openTemplates(tester, FakeNotesServer());

    await tester.tap(find.text('# 주간 회의'));
    await tester.pumpAndSettle();

    expect(find.text('템플릿이 없어요'), findsOneWidget);
    expect(find.text('스프린트 회고'), findsNothing);
  });

  testWidgets('채널을 바꾸는 동안 칩은 두고 템플릿 영역만 로딩을 보여준다', (tester) async {
    final server = FakeNotesServer();
    await openTemplates(tester, server);
    final hold = server.holdTemplates[11] = Completer<void>();

    await tester.tap(find.text('# 주간 회의'));
    await tester.pump();

    expect(find.text('# 회의록'), findsOneWidget);
    expect(
      tester
          .widget<NoteChoiceChip>(
            find.widgetWithText(NoteChoiceChip, '# 주간 회의'),
          )
          .selected,
      isTrue,
    );
    expect(find.byType(CoworkLoadingPane), findsOneWidget);
    expect(find.text('스프린트 회고'), findsNothing);

    hold.complete();
    await tester.pumpAndSettle();

    expect(find.byType(CoworkLoadingPane), findsNothing);
    expect(find.text('템플릿이 없어요'), findsOneWidget);
  });

  testWidgets('다른 채널을 고른 뒤 늦게 온 응답은 버린다', (tester) async {
    final server = FakeNotesServer();
    await openTemplates(tester, server);
    final hold = server.holdTemplates[11] = Completer<void>();

    await tester.tap(find.text('# 주간 회의'));
    await tester.pump();
    await tester.tap(find.text('# 회의록'));
    await tester.pumpAndSettle();
    expect(find.text('스프린트 회고'), findsOneWidget);

    hold.complete();
    await tester.pumpAndSettle();

    expect(find.text('스프린트 회고'), findsOneWidget);
    expect(find.text('템플릿이 없어요'), findsNothing);
  });

  testWidgets('기본 템플릿은 사용 중으로 보이고 삭제할 수 없다', (tester) async {
    final server = FakeNotesServer();
    await openEditor(tester, server, '주간 회의');

    expect(find.text('템플릿 편집'), findsOneWidget);
    expect(find.text('사용 중'), findsOneWidget);
    expect(find.text('참석자 목록 · 필수'), findsOneWidget);
    expect(find.text('날짜와 시간'), findsOneWidget);
    expect(
      find.text('기본 템플릿은 삭제할 수 없어요. 다른 템플릿을 기본으로 바꾼 뒤 삭제하세요.'),
      findsOneWidget,
    );

    await tester.tap(find.text('템플릿 삭제'));
    await tester.pumpAndSettle();

    expect(find.text('템플릿을 삭제할까요?'), findsNothing);
    expect(server.requests.where((r) => r.$1 == 'DELETE'), isEmpty);
  });

  testWidgets('이름을 고치면 편집 화면과 목록에 반영된다', (tester) async {
    await openEditor(tester, FakeNotesServer(), '스프린트 회고');

    await tester.tap(find.text('이름'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '회고');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CoworkButton, '저장'));
    await tester.pumpAndSettle();

    expect(find.text('회고'), findsOneWidget);

    await tester.tap(find.byIcon(AppIcon.back));
    await tester.pumpAndSettle();
    expect(find.text('회고'), findsOneWidget);
    expect(find.text('스프린트 회고'), findsNothing);
  });

  testWidgets('섹션을 추가·수정·삭제하면 바로 서버에 반영된다', (tester) async {
    final server = FakeNotesServer();
    await openEditor(tester, server, '스프린트 회고');
    List<Object?> serverSections() => [
      for (final section
          in server.templates[10]!.last['sections']
              as List<Map<String, dynamic>>)
        section['title'],
    ];

    // 추가: 제목 · 날짜 형식 · 필수.
    await tester.tap(find.text('+ 섹션 추가'));
    await tester.pumpAndSettle();
    expect(find.text('섹션 추가'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '다음 회고');
    await tester.tap(find.widgetWithText(NoteChoiceChip, '날짜'));
    await tester.tap(find.byType(CoworkSwitch));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CoworkButton, '추가'));
    await tester.pumpAndSettle();

    expect(find.text('다음 회고'), findsOneWidget);
    expect(find.text('날짜 · 필수'), findsOneWidget);
    expect(serverSections(), ['Keep', 'Problem', 'Try', '다음 회고']);

    // 수정: 행을 눌러 제목을 바꾼다.
    await tester.tap(find.text('Keep'));
    await tester.pumpAndSettle();
    expect(find.text('섹션 수정'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '잘한 점');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CoworkButton, '저장'));
    await tester.pumpAndSettle();

    expect(find.text('잘한 점'), findsOneWidget);
    expect(find.text('Keep'), findsNothing);

    // 삭제: 확인 창을 거친다.
    await tester.tap(deleteButtonOf('Problem'));
    await tester.pumpAndSettle();
    expect(find.text('‘Problem’ 섹션을 삭제할까요?'), findsOneWidget);
    await tester.tap(find.widgetWithText(CoworkButton, '삭제'));
    await tester.pumpAndSettle();

    expect(find.text('Problem'), findsNothing);
    expect(serverSections(), ['잘한 점', 'Try', '다음 회고']);
  });

  testWidgets('기본으로 설정하면 이전 기본 템플릿이 풀린다', (tester) async {
    final server = FakeNotesServer();
    await openEditor(tester, server, '스프린트 회고');

    await tester.tap(find.widgetWithText(CoworkButton, '기본으로 설정'));
    await tester.pumpAndSettle();

    expect(find.text('사용 중'), findsOneWidget);
    expect(server.templates[10]!.map((t) => t['isActive']), [false, true]);
  });

  testWidgets('기본이 아닌 템플릿은 확인 후 삭제하고 목록으로 돌아간다', (tester) async {
    final server = FakeNotesServer();
    await openEditor(tester, server, '스프린트 회고');

    await tester.tap(find.text('템플릿 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CoworkButton, '삭제'));
    await tester.pumpAndSettle();

    expect(find.text('템플릿을 삭제했어요.'), findsOneWidget);
    expect(find.text('회의록 템플릿'), findsOneWidget);
    expect(find.text('스프린트 회고'), findsNothing);
    expect(server.templates[10]!.map((t) => t['name']), ['주간 회의']);
  });
}
