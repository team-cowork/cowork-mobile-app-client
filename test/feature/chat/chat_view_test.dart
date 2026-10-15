import 'package:cowork_app/feature/chat/presentation/views/chat_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_server.dart';

void main() {
  Future<void> pumpChat(WidgetTester tester, FakeChatServer server) async {
    await tester.pumpWidget(
      chatTestApp(server, theme: AppTheme.dark(), home: const ChatView()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('첫 팀의 이름과 채널을 서버에서 읽어 보여준다', (tester) async {
    await pumpChat(tester, FakeChatServer());

    expect(find.text('코워크'), findsOneWidget);
    expect(find.text('일반'), findsOneWidget);
    expect(find.text('배포'), findsOneWidget);
    expect(find.text('시안'), findsNothing);
  });

  testWidgets('단축 바에서 다른 팀을 누르면 그 팀의 채널로 바뀐다', (tester) async {
    await pumpChat(tester, FakeChatServer());

    await tester.tap(find.text('디'));
    await tester.pumpAndSettle();

    expect(find.text('디자인팀'), findsOneWidget);
    expect(find.text('시안'), findsOneWidget);
    expect(find.text('일반'), findsNothing);
  });

  testWidgets('팀 목록 조회가 실패하면 채널이 아니라 팀 단계 실패로 보여준다', (tester) async {
    final server = FakeChatServer()
      ..failTeams = const ServerFailure(503, '서비스를 잠시 사용할 수 없습니다.');
    await pumpChat(tester, server);

    expect(find.text('홈을 불러오지 못했어요'), findsOneWidget);
    expect(find.text('팀 목록 조회 실패 · (503) 서비스를 잠시 사용할 수 없습니다.'), findsOneWidget);
    expect(find.textContaining('채널'), findsNothing);
  });

  testWidgets('채널 목록 조회가 실패하면 채널 단계 실패로 보여준다', (tester) async {
    final server = FakeChatServer()
      ..failChannels = const ServerFailure(403, '팀 멤버만 접근할 수 있습니다.');
    await pumpChat(tester, server);

    expect(find.text('채널 목록 조회 실패 · (403) 팀 멤버만 접근할 수 있습니다.'), findsOneWidget);
    expect(find.textContaining('팀 목록'), findsNothing);
  });

  testWidgets('연결이 끊겨 실패하면 네트워크 문제로 보여주고, 다시 시도로 복구한다', (tester) async {
    final server = FakeChatServer()..failTeams = const ServerFailure.offline();
    await pumpChat(tester, server);

    expect(find.text('팀 목록 조회 실패 · 네트워크에 연결할 수 없습니다.'), findsOneWidget);

    server.failTeams = null;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('코워크'), findsOneWidget);
    expect(find.text('일반'), findsOneWidget);
  });

  testWidgets('속한 팀이 없으면 빈 화면을 보여준다', (tester) async {
    await pumpChat(tester, FakeChatServer(teams: []));

    expect(find.text('아직 속한 팀이 없어요'), findsOneWidget);
    expect(find.text('홈을 불러오지 못했어요'), findsNothing);
  });
}
