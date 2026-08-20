import 'package:cowork_app/feature/notes/domain/note.dart';
import 'package:cowork_app/feature/notes/presentation/views/note_detail_view.dart';
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
  ],
);

void main() {
  testWidgets('카드를 누르면 상세 화면이 섹션과 액션 아이템을 렌더링한다', (tester) async {
    // 내용·안건·결정사항까지 더해지면 액션 아이템이 기본 화면(600) 밖으로 밀려
    // ListView가 빌드하지 않으므로 세로를 넉넉히 준다.
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.dark(), routerConfig: _notesRouter()),
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
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.dark(), routerConfig: _notesRouter()),
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

  testWidgets('참여자가 5명을 넘으면 아바타 4개 + 카운터만 표시하고 탭하면 전체 목록이 나온다', (
    tester,
  ) async {
    const note = Note(
      id: 999,
      title: '대규모 회의',
      tags: [],
      summary: '',
      author: NoteAuthor(
        authorId: 99,
        name: 'junjuny',
        initial: '준',
        date: '03.12',
      ),
      participants: ['도', '서', '민', '가', '나', '다', '라'],
    );

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const NoteDetailView(note: note)),
    );
    await tester.pumpAndSettle();

    // 7명 → 아바타 4개 + `+3` 카운터. 나머지 이니셜은 스택에 없다.
    expect(find.text('+3'), findsOneWidget);
    expect(find.text('라'), findsNothing);

    await tester.tap(find.text('+3'));
    await tester.pumpAndSettle();

    // 시트에 전체 7명이 나온다. 각 행은 아바타 + 라벨이라 이니셜은 2번 나타난다.
    expect(find.text('참여자 7명'), findsOneWidget);
    expect(find.text('라'), findsNWidgets(2));
  });
}
