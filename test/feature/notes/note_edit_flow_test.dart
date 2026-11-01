import 'dart:convert';

import 'package:cowork_app/feature/notes/domain/note.dart';
import 'package:cowork_app/feature/notes/presentation/views/note_detail_view.dart';
import 'package:cowork_app/feature/notes/presentation/views/note_edit_view.dart';
import 'package:cowork_app/feature/notes/presentation/views/notes_view.dart';
import 'package:cowork_app/feature/profile/data/profile_store.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'notes_test_server.dart';

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

Future<void> _openNote(
  WidgetTester tester,
  String title, [
  FakeNotesServer? server,
]) async {
  await tester.pumpWidget(
    notesRouterTestApp(_notesRouter(), server ?? FakeNotesServer()),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

void main() {
  // 로그인 직후 AuthBloc 이 채워 두는 값. 가짜 서버의 작성자 1 이 나다.
  setUp(() => ProfileStore.instance.currentUserId = 1);

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

  testWidgets('저장하면 템플릿 순서대로 본문을 보내고 템플릿에 없는 섹션도 남긴다', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final server = FakeNotesServer();
    await _openNote(tester, '2026 1분기 킥오프 회의', server);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, '예: 2026-11-03 14:00'),
      '2026-11-03 14:00',
    );
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    final content =
        jsonDecode(server.notes.first['content'] as String)
            as Map<String, dynamic>;
    expect(content.keys, ['참석자', '안건', '결정 사항', '액션 아이템', '다음 회의', '요약']);
    expect(content['다음 회의'], '2026-11-03 14:00');
    expect(content['요약'], '분기 목표 정렬 및 팀별 OKR 확정.');
  });
}
