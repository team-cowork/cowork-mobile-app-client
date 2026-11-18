import 'package:cowork_app/feature/channel/presentation/views/chat_view.dart';
import 'package:cowork_app/feature/profile/data/profile_store.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../channel/chat_test_server.dart';

/// 홈 → 팀 이름 → 팀 메뉴. 팀 1 `코워크` 는 내가 소유자, 팀 2 `디자인팀` 은 멤버다.
void main() {
  setUp(() {
    ProfileStore.instance.currentUserId = 1;
    // 기본 800x600 뷰에서는 팀 메뉴 시트가 다 들어가지 않아 폰 크기로 맞춘다.
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(400, 900);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  });
  tearDown(() => ProfileStore.instance.currentUserId = null);

  Future<void> pumpChat(WidgetTester tester, FakeChatServer server) async {
    await tester.pumpWidget(
      chatTestApp(server, theme: AppTheme.dark(), home: const ChatView()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openMenu(WidgetTester tester, String teamName) async {
    await tester.tap(find.text(teamName));
    await tester.pumpAndSettle();
  }

  /// 디자인팀(멤버)으로 옮겨 팀 메뉴를 연다.
  Future<void> openMemberTeamMenu(WidgetTester tester) async {
    await tester.tap(find.text('디'));
    await tester.pumpAndSettle();
    await openMenu(tester, '디자인팀');
  }

  testWidgets('알림 설정은 메뉴에 없다', (tester) async {
    await pumpChat(tester, FakeChatServer());

    await openMenu(tester, '코워크');

    expect(find.text('팀 설정'), findsOneWidget);
    expect(find.text('알림 설정'), findsNothing);
  });

  testWidgets('초대 권한이 없는 팀에서는 멤버 초대를 보이지 않는다', (tester) async {
    await pumpChat(tester, FakeChatServer());

    await openMenu(tester, '코워크');
    expect(find.text('멤버 초대'), findsOneWidget);
    await tester.tap(find.byIcon(AppIcon.close));
    await tester.pumpAndSettle();

    await openMemberTeamMenu(tester);
    expect(find.text('멤버 초대'), findsNothing);
  });

  testWidgets('소유자에게는 팀 나가기를 보이지 않는다', (tester) async {
    await pumpChat(tester, FakeChatServer());

    await openMenu(tester, '코워크');

    expect(find.text('팀 나가기'), findsNothing);
  });

  testWidgets('소유자인지는 myRole 이 아니라 팀 상세의 ownerId 로 본다', (tester) async {
    // 소유권을 막 넘겨받아 목록의 myRole 이 아직 MEMBER 인 순간.
    final server = FakeChatServer(
      teams: [
        {
          'id': 1,
          'name': '코워크',
          'iconUrl': null,
          'myRole': 'MEMBER',
          'ownerId': 1,
        },
      ],
    );
    await pumpChat(tester, server);

    await openMenu(tester, '코워크');

    expect(server.requests, contains('GET /team/teams/1'));
    expect(find.text('팀 나가기'), findsNothing);
  });

  testWidgets('팀 상세를 못 읽으면 팀 나가기를 보이고 서버가 막게 둔다', (tester) async {
    final server = FakeChatServer()..failTeam = const ServerFailure(503);
    await pumpChat(tester, server);

    await openMenu(tester, '코워크');

    expect(find.text('팀 나가기'), findsOneWidget);
  });

  testWidgets('팀을 나가면 남은 팀으로 옮기고 알린다', (tester) async {
    final server = FakeChatServer();
    await pumpChat(tester, server);
    await openMemberTeamMenu(tester);

    await tester.tap(find.text('팀 나가기'));
    await tester.pumpAndSettle();
    expect(find.text('팀에서 나갈까요?'), findsOneWidget);
    await tester.tap(find.text('나가기'));
    await tester.pumpAndSettle();

    expect(server.requests, contains('DELETE /team/teams/2/members/1'));
    expect(find.text('디자인팀 팀에서 나왔어요.'), findsOneWidget);
    expect(find.text('코워크'), findsOneWidget);
    expect(find.text('디'), findsNothing);
  });

  testWidgets('나가기가 실패하면 다이얼로그에 사유를 두고 팀에 남는다', (tester) async {
    final server = FakeChatServer()
      ..failLeave = const ServerFailure(403, '권한이 없습니다.');
    await pumpChat(tester, server);
    await openMemberTeamMenu(tester);

    await tester.tap(find.text('팀 나가기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('나가기'));
    await tester.pumpAndSettle();

    expect(find.textContaining('팀을 나가지 못했어요.'), findsOneWidget);
    expect(find.textContaining('권한이 없습니다.'), findsOneWidget);

    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(find.text('디자인팀'), findsOneWidget);
  });

  testWidgets('나가기를 취소하면 아무것도 보내지 않는다', (tester) async {
    final server = FakeChatServer();
    await pumpChat(tester, server);
    await openMemberTeamMenu(tester);
    server.requests.clear();

    await tester.tap(find.text('팀 나가기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(server.requests, isEmpty);
    expect(find.text('디자인팀'), findsOneWidget);
  });

  group('팀 설정', () {
    /// 팀 설정 화면 대신 `삭제됨` / `뒤로` 버튼만 있는 화면을 둔 앱.
    Future<void> pumpWithSettings(
      WidgetTester tester,
      FakeChatServer server,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => const ChatView()),
          GoRoute(
            path: '/teams/:teamId/settings',
            builder: (context, state) => Scaffold(
              body: Column(
                children: [
                  Text('설정 ${state.pathParameters['teamId']}'),
                  TextButton(
                    onPressed: () => context.pop(true),
                    child: const Text('삭제됨'),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('뒤로'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        chatTestApp(server, theme: AppTheme.dark(), router: router),
      );
      await tester.pumpAndSettle();
      await openMenu(tester, '코워크');
      await tester.tap(find.text('팀 설정'));
      await tester.pumpAndSettle();
    }

    testWidgets('보던 팀의 설정을 연다', (tester) async {
      await pumpWithSettings(tester, FakeChatServer());

      expect(find.text('설정 1'), findsOneWidget);
    });

    testWidgets('설정에서 팀을 지우고 돌아오면 남은 팀으로 옮기고 알린다', (tester) async {
      final server = FakeChatServer();
      await pumpWithSettings(tester, server);

      await tester.tap(find.text('삭제됨'));
      await tester.pumpAndSettle();

      expect(find.text('팀을 삭제했어요.'), findsOneWidget);
      expect(find.text('디자인팀'), findsOneWidget);
    });

    testWidgets('설정에서 이름을 바꾸고 돌아오면 새 이름이 보인다', (tester) async {
      final server = FakeChatServer();
      await pumpWithSettings(tester, server);
      server.teams.first['name'] = '새 이름';

      await tester.tap(find.text('뒤로'));
      await tester.pumpAndSettle();

      expect(find.text('새 이름'), findsOneWidget);
      // 채널 목록은 다시 읽지 않고 그대로 둔다.
      expect(find.text('일반'), findsOneWidget);
    });
  });
}
