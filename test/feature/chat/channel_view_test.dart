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

  Finder messageText(String text) => find.text(text, findRichText: true);

  final myMessage = messageJson('m2', 1, '내 메시지');
  final otherMessage = messageJson('m1', 2, '남의 메시지');

  testWidgets('내 메시지를 길게 눌러 고치면 고친 내용으로 바뀐다', (tester) async {
    final gateway = FakeMessageGateway(messages: [myMessage, otherMessage]);
    await pumpChannel(tester, gateway);

    await tester.longPress(messageText('내 메시지'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('메시지 수정'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '고친 내용');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(gateway.bodies['PATCH /chat/chat/channels/10/messages/m2'], {
      'content': '고친 내용',
    });
    expect(messageText('고친 내용'), findsOneWidget);
    expect(messageText('내 메시지'), findsNothing);
  });

  testWidgets('내 메시지를 길게 눌러 삭제를 확인하면 목록에서 빠진다', (tester) async {
    final gateway = FakeMessageGateway(messages: [myMessage, otherMessage]);
    await pumpChannel(tester, gateway);

    await tester.longPress(messageText('내 메시지'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('메시지 삭제'));
    await tester.pumpAndSettle();
    expect(find.text('메시지를 삭제할까요?'), findsOneWidget);
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(
      gateway.calls,
      contains('DELETE /chat/chat/channels/10/messages/m2'),
    );
    expect(messageText('내 메시지'), findsNothing);
    expect(messageText('남의 메시지'), findsOneWidget);
  });

  testWidgets('삭제 확인에서 취소하면 지우지 않는다', (tester) async {
    final gateway = FakeMessageGateway(messages: [myMessage]);
    await pumpChannel(tester, gateway);

    await tester.longPress(messageText('내 메시지'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('메시지 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(gateway.calls, isNot(contains(startsWith('DELETE'))));
    expect(messageText('내 메시지'), findsOneWidget);
  });

  testWidgets('남의 메시지는 길게 눌러도 메뉴가 뜨지 않는다', (tester) async {
    await pumpChannel(
      tester,
      FakeMessageGateway(messages: [myMessage, otherMessage]),
    );

    await tester.longPress(messageText('남의 메시지'));
    await tester.pumpAndSettle();

    expect(find.text('메시지 수정'), findsNothing);
  });

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
