import 'package:cowork_app/feature/notes/presentation/views/notes_view.dart';
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

  testWidgets('새 노트 버튼으로 시트를 열고 템플릿을 선택한다', (tester) async {
    await tester.pumpWidget(notesTestApp(const NotesView(), FakeNotesServer()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('새 노트').last);
    await tester.pumpAndSettle();

    expect(find.text('노트 제목을 입력하세요'), findsOneWidget);
    expect(find.text('노트 만들기'), findsOneWidget);

    // 기본 선택은 첫 템플릿, 탭하면 선택이 옮겨간다.
    CoworkOptionCard cardOf(String label) =>
        tester.widget(find.widgetWithText(CoworkOptionCard, label));
    expect(cardOf('자유 양식').selected, isTrue);

    await tester.tap(find.text('스프린트 회고'));
    await tester.pumpAndSettle();

    expect(cardOf('자유 양식').selected, isFalse);
    expect(cardOf('스프린트 회고').selected, isTrue);
  });

  testWidgets('노트를 만들면 목록 맨 앞에 추가된다', (tester) async {
    await tester.pumpWidget(notesTestApp(const NotesView(), FakeNotesServer()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('새 노트').last);
    await tester.pumpAndSettle();

    // 제목이 비면 CTA 비활성.
    final button = find.widgetWithText(CoworkButton, '노트 만들기');
    expect(tester.widget<CoworkButton>(button).enabled, isFalse);

    await tester.enterText(find.byType(TextFormField).first, '주간 스크럼');
    await tester.enterText(find.byType(TextFormField).last, '이번 주 진행 상황 공유');
    await tester.pumpAndSettle();

    expect(tester.widget<CoworkButton>(button).enabled, isTrue);

    await tester.tap(button);
    await tester.pumpAndSettle();

    // 시트가 닫히고 목록 카드로 보인다.
    expect(find.text('노트 만들기'), findsNothing);
    expect(find.text('주간 스크럼'), findsOneWidget);
    expect(find.text('이번 주 진행 상황 공유'), findsOneWidget);
    expect(find.text('회의록을 만들었어요.'), findsOneWidget);
  });

  testWidgets('작성이 실패하면 시트에 사유를 보여주고 입력값과 목록을 남긴다', (tester) async {
    final server = FakeNotesServer()..failCreate = (403, '채널 멤버만 작성할 수 있습니다.');
    await tester.pumpWidget(notesTestApp(const NotesView(), server));
    await tester.pumpAndSettle();

    await tester.tap(find.text('새 노트').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '주간 스크럼');
    await tester.pumpAndSettle();

    final button = find.widgetWithText(CoworkButton, '노트 만들기');
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('노트를 만들지 못했어요'), findsOneWidget);
    expect(find.text('(403) 채널 멤버만 작성할 수 있습니다.'), findsOneWidget);
    // 시트 뒤 목록은 오류 화면으로 바뀌지 않는다.
    expect(find.text('회의록을 불러오지 못했어요'), findsNothing);
    expect(find.text('2026 1분기 킥오프 회의'), findsOneWidget);
    // 시트는 입력값을 둔 채 열려 있고, 다시 누를 수 있다.
    expect(find.text('주간 스크럼'), findsOneWidget);
    expect(tester.widget<CoworkButton>(button).enabled, isTrue);

    server.failCreate = null;
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('노트 만들기'), findsNothing);
    expect(find.text('주간 스크럼'), findsOneWidget);
    expect(server.notes, hasLength(4));
  });
}
