import 'package:cowork_app/core/presentation/main_shell.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('탭을 누르면 해당 화면으로 전환된다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const MainShell()),
    );
    await tester.pumpAndSettle();

    // 채널 탭에서 시작한다.
    expect(find.text('채널 화면을 준비 중이에요'), findsOneWidget);
    expect(find.text('새 노트'), findsNothing);

    await tester.tap(find.text('회의록'));
    await tester.pumpAndSettle();
    expect(find.text('새 노트'), findsOneWidget);
  });
}
