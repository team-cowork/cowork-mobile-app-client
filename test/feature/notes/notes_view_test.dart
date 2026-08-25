import 'package:cowork_app/feature/notes/presentation/views/notes_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('회의록 화면이 헤더와 시드 카드를 렌더링한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const NotesView()),
    );
    await tester.pumpAndSettle();

    // 헤더
    expect(find.text('회의록'), findsWidgets);
    expect(find.text('새 노트'), findsOneWidget);
    // 시드된 카드 제목
    expect(find.text('2026 1분기 킥오프 회의'), findsOneWidget);
    expect(find.text('스프린트 회고 #3'), findsOneWidget);
  });
}
