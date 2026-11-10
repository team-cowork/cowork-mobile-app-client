import 'package:cowork_app/app/main_shell.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../feature/channel/chat_test_server.dart';
import '../feature/notes/notes_test_server.dart';

void main() {
  testWidgets('탭을 누르면 해당 화면으로 전환된다', (tester) async {
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: notesRepositoryOf(FakeNotesServer()),
        child: chatTestApp(
          FakeChatServer(),
          theme: AppTheme.dark(),
          home: const MainShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 채널 탭에서 시작한다.
    expect(find.text('코워크'), findsOneWidget);
    expect(find.text('새 노트'), findsNothing);

    final navBar = find.byType(CoworkBottomNavigationBar);
    await tester.tap(find.descendant(of: navBar, matching: find.text('회의록')));
    await tester.pumpAndSettle();
    expect(find.text('새 노트'), findsOneWidget);
  });
}
