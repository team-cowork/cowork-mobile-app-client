import 'package:cowork_app/feature/notes/presentation/views/notes_view.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notes_test_server.dart';

void main() {
  testWidgets('회의록 화면이 헤더와 서버가 준 카드를 렌더링한다', (tester) async {
    await tester.pumpWidget(notesTestApp(const NotesView(), FakeNotesServer()));
    await tester.pumpAndSettle();

    // 헤더
    expect(find.text('회의록'), findsWidgets);
    expect(find.text('새 노트'), findsOneWidget);
    // 서버가 준 카드 제목
    expect(find.text('2026 1분기 킥오프 회의'), findsOneWidget);
    expect(find.text('스프린트 회고 #3'), findsOneWidget);
  });
}
