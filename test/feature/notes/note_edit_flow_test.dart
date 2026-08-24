import 'package:cowork_app/feature/notes/domain/note.dart';
import 'package:cowork_app/feature/notes/presentation/views/note_detail_view.dart';
import 'package:cowork_app/feature/notes/presentation/views/note_edit_view.dart';
import 'package:cowork_app/feature/notes/presentation/views/notes_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter _notesRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const NotesView()),
    GoRoute(
      path: '/notes/detail',
      builder: (context, state) => NoteDetailView(note: state.extra! as Note),
    ),
    GoRoute(
      path: '/notes/edit',
      builder: (context, state) => NoteEditView(note: state.extra! as Note),
    ),
  ],
);

Future<void> _openNote(WidgetTester tester, String title) async {
  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.dark(), routerConfig: _notesRouter()),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('남의 회의록 상세에는 수정 아이콘이 없다', (tester) async {
    await _openNote(tester, '디자인 시스템 리뷰'); // 작성자 도윤 (내 것 아님)
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('내 회의록 상세에는 수정 아이콘이 있다', (tester) async {
    await _openNote(tester, '2026 1분기 킥오프 회의'); // 작성자 user_me
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
  });

  testWidgets('수정 아이콘 → 편집 화면에서 제목을 바꿔 저장하면 상세에 반영된다', (tester) async {
    await _openNote(tester, '2026 1분기 킥오프 회의');

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // 편집 화면 진입 확인 (저장 버튼 + 섹션 헤더).
    expect(find.text('저장'), findsOneWidget);
    expect(find.text('안건'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '3월 스프린트 플래닝 (수정)');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    // 상세로 복귀하며 새 제목이 렌더된다.
    expect(find.text('3월 스프린트 플래닝 (수정)'), findsOneWidget);
    expect(find.text('저장'), findsNothing);

    // 목록으로 돌아가도 카드가 갱신된 제목을 보여준다.
    await tester.tap(find.byIcon(AppIcon.back));
    await tester.pumpAndSettle();
    expect(find.text('3월 스프린트 플래닝 (수정)'), findsOneWidget);
    expect(find.text('2026 1분기 킥오프 회의'), findsNothing);
  });
}
