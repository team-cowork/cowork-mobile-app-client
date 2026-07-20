import 'package:cowork_app/feature/notes/presentation/views/notes_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('카드를 누르면 상세 화면이 섹션과 액션 아이템을 렌더링한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const NotesView()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('2026 1분기 킥오프 회의'));
    await tester.pumpAndSettle();

    expect(find.text('안건'), findsOneWidget);
    expect(find.text('결정 사항'), findsOneWidget);
    expect(find.text('액션 아이템'), findsOneWidget);
    expect(find.text('확정'), findsOneWidget);
    expect(find.text('이슈 트래커 칸반 스펙 문서화 (민재)'), findsOneWidget);
  });

  testWidgets('액션 아이템을 누르면 체크 상태가 토글된다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const NotesView()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('2026 1분기 킥오프 회의'));
    await tester.pumpAndSettle();

    // 시드에서 체크된 항목은 1개.
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.text('음성 채널 인원 제한 정책 확정 (서연)'));
    await tester.pump();

    expect(find.byIcon(Icons.check), findsNWidgets(2));
  });
}
