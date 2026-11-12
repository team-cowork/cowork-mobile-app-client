import 'package:cowork_app/feature/notes/presentation/views/notes_view.dart';
import 'package:cowork_app/feature/profile/data/profile_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notes_test_server.dart';

/// 작성자 1(로그인 사용자)의 회의록.
const _mine = '2026 1분기 킥오프 회의';

/// 작성자 4의 회의록.
const _others = '스프린트 회고 #3';

void main() {
  setUp(() => ProfileStore.instance.currentUserId = 1);

  testWidgets('회의록 화면이 헤더와 서버가 준 카드를 렌더링한다', (tester) async {
    await tester.pumpWidget(notesTestApp(const NotesView(), FakeNotesServer()));
    await tester.pumpAndSettle();

    // 헤더
    expect(find.text('회의록'), findsWidgets);
    expect(find.text('새 노트'), findsOneWidget);
    // 서버가 준 카드 제목
    expect(find.text(_mine), findsOneWidget);
    expect(find.text(_others), findsOneWidget);
  });

  group('밀어서 삭제', () {
    late FakeNotesServer server;

    Future<void> swipe(WidgetTester tester, String title) async {
      await tester.drag(find.text(title), const Offset(-500, 0));
      await tester.pumpAndSettle();
    }

    /// 확인 다이얼로그에서 삭제를 누르고 서버 응답까지 반영한다.
    ///
    /// 카드가 빠지면 그릴 프레임이 없어 `pumpAndSettle` 이 바로 끝난다. 그 사이
    /// 삭제 요청은 아직 서버에 닿지 않았으므로 시간을 한 번 더 흘린다.
    Future<void> confirmDelete(WidgetTester tester) async {
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
    }

    bool deleted() => server.requests.any((r) => r.$1 == 'DELETE');

    setUp(() => server = FakeNotesServer());

    testWidgets('내 회의록은 확인 후 목록에서 빠지고 서버에 지운다', (tester) async {
      await tester.pumpWidget(notesTestApp(const NotesView(), server));
      await tester.pumpAndSettle();

      await swipe(tester, _mine);
      expect(find.text('회의록을 삭제할까요?'), findsOneWidget);
      await confirmDelete(tester);

      expect(find.text(_mine), findsNothing);
      final deleteAt = server.requests.indexWhere((r) => r.$1 == 'DELETE');
      expect(
        server.requests[deleteAt].$2,
        '/channel/channels/10/meeting-notes/1',
      );
      // 지운 뒤 목록을 다시 읽어 서버와 맞춘다.
      expect(
        server.requests.skip(deleteAt + 1).map((r) => r.$1),
        contains('GET'),
      );
      expect(find.text(_mine), findsNothing);
    });

    testWidgets('취소하면 카드가 그대로 남고 서버에 묻지 않는다', (tester) async {
      await tester.pumpWidget(notesTestApp(const NotesView(), server));
      await tester.pumpAndSettle();

      await swipe(tester, _mine);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(find.text(_mine), findsOneWidget);
      expect(deleted(), isFalse);
    });

    testWidgets('남의 회의록은 밀어도 삭제를 묻지 않는다', (tester) async {
      await tester.pumpWidget(notesTestApp(const NotesView(), server));
      await tester.pumpAndSettle();

      await swipe(tester, _others);

      expect(find.text('회의록을 삭제할까요?'), findsNothing);
      expect(find.text(_others), findsOneWidget);
    });

    testWidgets('서버가 거절하면 카드를 되돌리고 사유를 알린다', (tester) async {
      server.failDelete = (403, '작성자만 삭제할 수 있습니다.');
      await tester.pumpWidget(notesTestApp(const NotesView(), server));
      await tester.pumpAndSettle();

      await swipe(tester, _mine);
      await confirmDelete(tester);

      expect(deleted(), isTrue);
      expect(find.text(_mine), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
