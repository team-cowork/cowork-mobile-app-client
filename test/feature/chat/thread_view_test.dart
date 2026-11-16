import 'package:cowork_app/core/network/chat_socket.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/chat/presentation/views/thread_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../channel/chat_test_server.dart';
import 'channel_message_test_server.dart';

void main() {
  Future<void> pumpThread(
    WidgetTester tester,
    FakeMessageGateway gateway,
    FakeChatSocket socket,
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
          RepositoryProvider<ChatSocket>.value(value: socket),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const ThreadView(channelId: 10, parentMessageId: 'm1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder messageText(String text) => find.text(text, findRichText: true);

  FakeMessageGateway gateway() => FakeMessageGateway(
    replies: [messageJson('r1', 2, '첫 답글', parentMessageId: 'm1')],
  );

  Future<void> tapSend(WidgetTester tester) => tester.tap(
    find.descendant(
      of: find.byType(CoworkMessageComposer),
      matching: find.byType(InkWell),
    ),
  );

  testWidgets('부모 메시지와 답글을 보여 준다', (tester) async {
    await pumpThread(tester, gateway(), FakeChatSocket());

    expect(find.text('# 백엔드'), findsOneWidget);
    expect(messageText('첫 번째'), findsOneWidget);
    expect(find.text('답글 1개'), findsOneWidget);
    expect(messageText('첫 답글'), findsOneWidget);
  });

  testWidgets('답글을 보내면 입력창이 비고, 저장된 답글이 소켓으로 오면 목록에 붙는다', (tester) async {
    final server = gateway();
    final socket = FakeChatSocket();
    await pumpThread(tester, server, socket);

    await tester.enterText(find.byType(TextField), '새 답글');
    await tapSend(tester);
    await tester.pumpAndSettle();

    final sent = server.bodies['POST /chat/chat/channels/10/messages']!;
    expect(sent['content'], '새 답글');
    expect(sent['parentMessageId'], 'm1');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '');

    socket.push(
      'message',
      messageJson(
        'r2',
        1,
        '새 답글',
        parentMessageId: 'm1',
        clientMessageId: sent['clientMessageId'] as String,
      ),
    );
    await tester.pumpAndSettle();

    expect(messageText('새 답글'), findsOneWidget);
    expect(find.text('답글 2개'), findsOneWidget);

    // 저장 확인을 기다리는 타이머가 남지 않게 화면을 닫는다.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('답글 전송이 실패하면 사유를 알린다', (tester) async {
    final server = gateway();
    await pumpThread(tester, server, FakeChatSocket());
    server.failing = 'POST /chat/chat/channels/10/messages';

    await tester.enterText(find.byType(TextField), '실패할 답글');
    await tapSend(tester);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(messageText('첫 답글'), findsOneWidget);
  });

  testWidgets('불러오지 못하면 에러 화면에서 다시 시도할 수 있다', (tester) async {
    final server = gateway()..failing = 'GET /channel/channels/10';
    await pumpThread(tester, server, FakeChatSocket());

    expect(find.text('스레드를 불러오지 못했어요'), findsOneWidget);

    server.failing = null;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(messageText('첫 번째'), findsOneWidget);
  });
}
