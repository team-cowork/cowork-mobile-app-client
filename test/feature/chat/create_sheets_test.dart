import 'package:cowork_app/feature/chat/presentation/views/chat_view.dart';
import 'package:cowork_app/feature/chat/presentation/widgets/create_sheets.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 기본 800x600 뷰에서는 시트 하단 CTA가 화면 밖이라 폰 크기로 맞춘다.
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(400, 900);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  Future<void> pumpChat(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const ChatView()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('새 채널 시트에서 유형·공개 범위를 고르고 이름이 있어야 만들 수 있다', (tester) async {
    await pumpChat(tester);

    await tester.tap(find.byType(CoworkIconButton).first);
    await tester.pumpAndSettle();

    CoworkOptionCard typeOf(String label) =>
        tester.widget(find.widgetWithText(CoworkOptionCard, label));
    SelectableCard visibilityOf(String label) =>
        tester.widget(find.widgetWithText(SelectableCard, label));

    // 기본값은 일반 채팅 · 공개.
    expect(typeOf('일반 채팅').selected, isTrue);
    expect(visibilityOf('🌐 공개').selected, isTrue);

    await tester.tap(find.widgetWithText(CoworkOptionCard, '음성'));
    await tester.tap(find.widgetWithText(SelectableCard, '🔒 비공개'));
    await tester.pumpAndSettle();

    expect(typeOf('일반 채팅').selected, isFalse);
    expect(typeOf('음성').selected, isTrue);
    expect(visibilityOf('🌐 공개').selected, isFalse);
    expect(visibilityOf('🔒 비공개').selected, isTrue);

    // 이름이 비면 CTA 비활성.
    final button = find.widgetWithText(CoworkButton, '채널 만들기');
    expect(tester.widget<CoworkButton>(button).enabled, isFalse);

    await tester.enterText(find.byType(TextFormField), '배포-알림');
    await tester.pumpAndSettle();
    expect(tester.widget<CoworkButton>(button).enabled, isTrue);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('채널 만들기'), findsNothing);
  });

  testWidgets('새 프로젝트 시트에서 템플릿을 고르고 이름이 있어야 만들 수 있다', (tester) async {
    await pumpChat(tester);

    await tester.tap(find.text('코워크'));
    await tester.pumpAndSettle();

    SelectableCard templateOf(String label) =>
        tester.widget(find.widgetWithText(SelectableCard, label));

    // 기본 선택은 첫 템플릿, 탭하면 선택이 옮겨간다.
    expect(templateOf('개발 프로젝트').selected, isTrue);
    // 빈 프로젝트만 채널 칩 줄이 없다.
    expect(find.text('# 백엔드'), findsOneWidget);
    expect(find.text('채널 없이 시작'), findsOneWidget);

    await tester.tap(find.widgetWithText(SelectableCard, '운영 프로젝트'));
    await tester.pumpAndSettle();

    expect(templateOf('개발 프로젝트').selected, isFalse);
    expect(templateOf('운영 프로젝트').selected, isTrue);

    final button = find.widgetWithText(CoworkButton, '프로젝트 만들기');
    expect(tester.widget<CoworkButton>(button).enabled, isFalse);

    await tester.enterText(find.byType(TextFormField), '마케팅');
    await tester.pumpAndSettle();
    expect(tester.widget<CoworkButton>(button).enabled, isTrue);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('프로젝트 만들기'), findsNothing);
  });
}
