import 'package:cowork_app/feature/chat/presentation/views/chat_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_server.dart';

void main() {
  Future<void> pumpChat(
    WidgetTester tester,
    FakeChatServer server, {
    FakeChatSocket? socket,
  }) async {
    await tester.pumpWidget(
      chatTestApp(
        server,
        socket: socket,
        theme: AppTheme.dark(),
        home: const ChatView(),
      ),
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

  group('소켓', () {
    late FakeChatSocket socket;

    setUp(() => socket = FakeChatSocket());

    /// 서버가 팀 방으로 보내는 채널 payload. REST 와 달리 id 가 `channelId` 다.
    Map<String, dynamic> channel(int id, String name, {int teamId = 1}) => {
      'channelId': id,
      'teamId': teamId,
      'projectId': null,
      'name': name,
      'type': 'TEXT',
      'viewType': 'TEXT',
      'isPrivate': false,
    };

    testWidgets('보고 있는 팀 방만 구독하고, 팀을 바꾸면 구독도 옮긴다', (tester) async {
      await pumpChat(tester, FakeChatServer(), socket: socket);
      expect(socket.joined, {1});

      await tester.tap(find.text('디'));
      await tester.pumpAndSettle();
      expect(socket.joined, {2});
    });

    testWidgets('다른 곳에서 만든 채널이 목록 끝에 붙는다', (tester) async {
      await pumpChat(tester, FakeChatServer(), socket: socket);

      socket.push('channel:created', channel(50, '웹에서-만듦'));
      await tester.pumpAndSettle();

      expect(find.text('웹에서-만듦'), findsOneWidget);
      expect(find.text('일반'), findsOneWidget);
    });

    testWidgets('다른 팀의 채널 이벤트는 반영하지 않는다', (tester) async {
      await pumpChat(tester, FakeChatServer(), socket: socket);

      socket.push('channel:created', channel(50, '남의-팀', teamId: 2));
      await tester.pumpAndSettle();

      expect(find.text('남의-팀'), findsNothing);
    });

    testWidgets('바뀐 채널은 그 자리에서 바뀌고, 지워지거나 못 읽게 된 채널은 빠진다', (tester) async {
      await pumpChat(tester, FakeChatServer(), socket: socket);

      socket.push('channel:updated', channel(10, '공지'));
      await tester.pumpAndSettle();
      expect(find.text('공지'), findsOneWidget);
      expect(find.text('일반'), findsNothing);

      socket.push('channel:deleted', {'channelId': 10, 'teamId': 1});
      await tester.pumpAndSettle();
      expect(find.text('공지'), findsNothing);

      socket.push('channel:access:revoked', {'channelId': 11});
      await tester.pumpAndSettle();
      expect(find.text('배포'), findsNothing);
    });

    testWidgets('내가 만든 채널이 이벤트로 다시 와도 한 번만 보인다', (tester) async {
      // 기본 800x600 에서는 시트 하단 CTA 가 화면 밖이라 폰 크기로 맞춘다.
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final server = FakeChatServer();
      await pumpChat(tester, server, socket: socket);

      await tester.tap(find.text('코워크'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('채널 만들기'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '새-채널');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(CoworkButton, '채널 만들기'));
      await tester.pumpAndSettle();
      expect(server.created, hasLength(1));

      // 가짜 서버가 붙인 id(100)로 서버 이벤트가 뒤따라온다.
      socket.push('channel:created', channel(100, '새-채널'));
      await tester.pumpAndSettle();

      expect(find.text('새-채널'), findsOneWidget);
    });

    testWidgets('보던 팀에서 빠지면 남은 팀으로 옮기고 구독도 옮긴다', (tester) async {
      await pumpChat(tester, FakeChatServer(), socket: socket);

      socket.push('team:access:revoked', {'teamId': 1});
      await tester.pumpAndSettle();

      expect(find.text('디자인팀'), findsOneWidget);
      expect(find.text('시안'), findsOneWidget);
      expect(find.text('코'), findsNothing);
      expect(socket.joined, {2});
    });

    testWidgets('마지막 팀에서 빠지면 빈 화면이 되고 구독을 모두 끊는다', (tester) async {
      final server = FakeChatServer(
        teams: [
          {'id': 1, 'name': '코워크'},
        ],
      );
      await pumpChat(tester, server, socket: socket);

      socket.push('team:access:revoked', {'teamId': 1});
      await tester.pumpAndSettle();

      expect(find.text('아직 속한 팀이 없어요'), findsOneWidget);
      expect(socket.joined, isEmpty);
    });

    testWidgets('홈을 떠나면 팀 방 구독을 끊는다', (tester) async {
      await pumpChat(tester, FakeChatServer(), socket: socket);
      expect(socket.joined, {1});

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      expect(socket.joined, isEmpty);
    });
  });

  testWidgets('속한 팀이 없으면 빈 화면을 보여준다', (tester) async {
    await pumpChat(tester, FakeChatServer(teams: []));

    expect(find.text('아직 속한 팀이 없어요'), findsOneWidget);
    expect(find.text('홈을 불러오지 못했어요'), findsNothing);
  });
}
