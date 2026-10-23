import 'package:cowork_app/feature/chat/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/chat/presentation/views/channel_view.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:cowork_app/network/chat_socket.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'channel_message_test_server.dart';
import 'chat_test_server.dart';

void main() {
  Future<void> pumpChannel(
    WidgetTester tester,
    FakeMessageGateway gateway,
  ) async {
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
          RepositoryProvider<ChatSocket>.value(value: FakeChatSocket()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const ChannelView(channelId: 10),
              ),
              GoRoute(
                path: '/chat/channel/thread',
                builder: (_, _) => const Text('스레드'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('파일 메시지는 첨부파일 이름과 크기를 보여 준다', (tester) async {
    await pumpChannel(
      tester,
      FakeMessageGateway(
        messages: [
          {
            ...messageJson('m1', 2, '', type: 'FILE'),
            'attachments': [
              {'name': '기획서.pdf', 'size': 2048, 'mimeType': 'application/pdf'},
            ],
          },
        ],
      ),
    );

    expect(find.text('기획서.pdf'), findsOneWidget);
    expect(find.text('2.0 KB'), findsOneWidget);
  });
}
