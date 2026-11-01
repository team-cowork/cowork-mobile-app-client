import 'dart:async';

import 'package:cowork_app/app/app_router.dart';
import 'package:cowork_app/core/network/chat_socket.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../feature/channel/chat_test_server.dart';
import '../feature/chat/channel_message_test_server.dart';

void main() {
  /// 실제 채널 라우트를 [location] 에서 연다. 홈은 표시용 글자만 둔다.
  Future<GoRouter> pumpAt(
    WidgetTester tester,
    String location, {
    FakeChatSocket? socket,
  }) async {
    final gateway = FakeMessageGateway();
    final router = GoRouter(
      initialLocation: location,
      routes: [
        // 실제 홈처럼 Scaffold 가 있어야 닫힌 뒤 스낵바가 보인다.
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('홈')),
        ),
        channelRoute,
      ],
    );
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(
            value: ChannelRepository.withDio(messageDio(gateway, 'channel')),
          ),
          RepositoryProvider.value(
            value: MessageRepository.withDio(
              chat: messageDio(gateway, 'chat'),
              user: messageDio(gateway, 'user'),
            ),
          ),
          RepositoryProvider.value(
            value: ProfileRepository.withDio(messageDio(gateway, 'user')),
          ),
          RepositoryProvider<ChatSocket>.value(
            value: socket ?? FakeChatSocket(),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('경로의 채널 id 로 채널 대화를 연다', (tester) async {
    await pumpAt(tester, '/chat/channel/10');

    // 가짜 게이트웨이의 채널 10 이름.
    expect(find.text('백엔드'), findsOneWidget);
  });

  testWidgets('채널 id 가 숫자가 아니면 홈으로 보낸다', (tester) async {
    final router = await pumpAt(tester, '/chat/channel/abc');

    expect(find.text('홈'), findsOneWidget);
    expect(router.state.uri.path, '/');
  });

  testWidgets('하위 화면도 채널 id 를 경로에 담는다', (tester) async {
    final router = await pumpAt(tester, '/chat/channel/10/settings');
    expect(router.state.pathParameters['channelId'], '10');

    await tester.tap(find.textContaining(RegExp(r'^멤버 \d+명$')));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/chat/channel/10/members');
  });

  testWidgets('채널을 더 볼 수 없게 되면 사유를 알리고 위에 열린 화면까지 닫는다', (tester) async {
    final socket = FakeChatSocket();
    final router = await pumpAt(tester, '/', socket: socket);
    unawaited(router.push('/chat/channel/10'));
    await tester.pumpAndSettle();
    unawaited(router.push('/chat/channel/10/settings'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/chat/channel/10/settings');

    socket.push('channel:access:revoked', {'channelId': 10});
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/');
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('이 채널에 더 이상 접근할 수 없어요.'), findsOneWidget);
  });

  testWidgets('채널로 바로 들어왔으면 닫을 때 홈으로 간다', (tester) async {
    final socket = FakeChatSocket();
    final router = await pumpAt(tester, '/chat/channel/10', socket: socket);

    socket.push('channel:deleted', {'channelId': 10, 'teamId': 1});
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/');
    expect(find.text('채널이 삭제됐어요.'), findsOneWidget);
  });
}
