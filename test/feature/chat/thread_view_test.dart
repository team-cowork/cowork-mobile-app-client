import 'package:cowork_app/core/network/chat_socket.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/chat/presentation/utils/attachment_opener.dart';
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
    FakeChatSocket socket, {
    UrlOpener? openUrl,
  }) async {
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
          home: ThreadView(
            channelId: 10,
            parentMessageId: 'm1',
            openUrl: openUrl ?? (_) async => true,
          ),
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

  Map<String, dynamic> namedThread({bool archived = false}) => {
    'id': 5,
    'channelId': 10,
    'name': '배포 논의',
    'parentMessageId': 'm1',
    'isArchived': archived,
  };

  Future<void> chooseMenu(WidgetTester tester, String item) async {
    await tester.tap(find.bySemanticsLabel('더보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  group('스레드 이름과 보관', () {
    testWidgets('이름이 있으면 머리에 이름을 보이고, 없으면 스레드라고 보인다', (tester) async {
      await pumpThread(
        tester,
        gateway()..threads = [namedThread(archived: true)],
        FakeChatSocket(),
      );

      expect(find.text('배포 논의'), findsOneWidget);
      expect(find.text('보관됨'), findsOneWidget);
    });

    testWidgets('스레드 이름을 읽지 못해도 답글은 보인다', (tester) async {
      await pumpThread(
        tester,
        gateway()..failing = 'GET /channel/channels/10/threads',
        FakeChatSocket(),
      );

      expect(find.text('스레드'), findsOneWidget);
      expect(messageText('첫 답글'), findsOneWidget);
    });

    testWidgets('스레드가 100개를 넘어도 이 스레드의 이름을 찾는다', (tester) async {
      final server = gateway()
        ..threads = [
          for (var i = 0; i < 100; i++)
            {
              'id': 100 + i,
              'channelId': 10,
              'name': '다른 스레드 $i',
              'parentMessageId': 'other$i',
              'isArchived': false,
            },
          namedThread(),
        ];
      await pumpThread(tester, server, FakeChatSocket());

      expect(find.text('배포 논의'), findsOneWidget);
    });

    testWidgets('스레드를 읽지 못한 채 이름을 바꾸면 다시 읽어 이미 있는 스레드를 고친다', (tester) async {
      final server = gateway()
        ..threads = [namedThread()]
        ..failingOnce.add('GET /channel/channels/10/threads');
      await pumpThread(tester, server, FakeChatSocket());
      expect(find.text('스레드'), findsOneWidget);

      await chooseMenu(tester, '이름 바꾸기');
      await tester.enterText(find.byType(TextField).last, '새 이름');
      await tester.pump();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(
        server.bodies.containsKey('POST /channel/channels/10/threads'),
        isFalse,
      );
      expect(server.bodies['PATCH /channel/channels/10/threads/5'], {
        'name': '새 이름',
      });
      expect(find.text('새 이름'), findsOneWidget);
    });

    testWidgets('스레드를 계속 못 읽으면 새로 만들지 않고 사유를 알린다', (tester) async {
      final server = gateway()
        ..threads = [namedThread()]
        ..failing = 'GET /channel/channels/10/threads';
      await pumpThread(tester, server, FakeChatSocket());

      await chooseMenu(tester, '이름 바꾸기');
      await tester.enterText(find.byType(TextField).last, '새 이름');
      await tester.pump();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(
        server.bodies.containsKey('POST /channel/channels/10/threads'),
        isFalse,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('이름을 붙인 적이 없으면 이름을 적어 스레드를 만든다', (tester) async {
      final server = gateway();
      await pumpThread(tester, server, FakeChatSocket());

      await chooseMenu(tester, '이름 바꾸기');
      await tester.enterText(find.byType(TextField).last, ' 배포 논의 ');
      await tester.pump();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(server.bodies['POST /channel/channels/10/threads'], {
        'name': '배포 논의',
        'parentMessageId': 'm1',
      });
      expect(find.text('배포 논의'), findsOneWidget);
    });

    testWidgets('이름이 있으면 이름만 바꾼다', (tester) async {
      final server = gateway()..threads = [namedThread()];
      await pumpThread(tester, server, FakeChatSocket());

      await chooseMenu(tester, '이름 바꾸기');
      await tester.enterText(find.byType(TextField).last, '새 이름');
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(server.bodies['PATCH /channel/channels/10/threads/5'], {
        'name': '새 이름',
      });
      expect(find.text('새 이름'), findsOneWidget);
    });

    testWidgets('이름을 붙인 스레드는 보관할 수 있다', (tester) async {
      final server = gateway()..threads = [namedThread()];
      await pumpThread(tester, server, FakeChatSocket());

      await chooseMenu(tester, '스레드 보관');

      expect(server.bodies['PATCH /channel/channels/10/threads/5'], {
        'isArchived': true,
      });
      expect(find.text('보관됨'), findsOneWidget);
    });

    testWidgets('보관된 스레드는 보관을 풀 수 있다', (tester) async {
      final server = gateway()..threads = [namedThread(archived: true)];
      await pumpThread(tester, server, FakeChatSocket());

      await chooseMenu(tester, '보관 풀기');

      expect(server.bodies['PATCH /channel/channels/10/threads/5'], {
        'isArchived': false,
      });
      expect(find.text('보관됨'), findsNothing);
    });

    testWidgets('보관하지 못하면 사유를 알리고 보관 상태는 그대로다', (tester) async {
      final server = gateway()
        ..threads = [namedThread()]
        ..failing = 'PATCH /channel/channels/10/threads/5';
      await pumpThread(tester, server, FakeChatSocket());

      await chooseMenu(tester, '스레드 보관');

      expect(find.text('보관됨'), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('이름을 붙인 적이 없으면 보관 메뉴가 없다', (tester) async {
      await pumpThread(tester, gateway(), FakeChatSocket());

      await tester.tap(find.bySemanticsLabel('더보기'));
      await tester.pumpAndSettle();

      expect(find.text('이름 바꾸기'), findsOneWidget);
      expect(find.text('스레드 보관'), findsNothing);
    });

    testWidgets('이름을 바꾸지 못하면 사유를 알리고 이름은 그대로다', (tester) async {
      final server = gateway()
        ..threads = [namedThread()]
        ..failing = 'PATCH /channel/channels/10/threads/5';
      await pumpThread(tester, server, FakeChatSocket());

      await chooseMenu(tester, '이름 바꾸기');
      await tester.enterText(find.byType(TextField).last, '새 이름');
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(find.text('배포 논의'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  testWidgets('답글의 첨부파일을 누르면 임시 주소로 연다', (tester) async {
    final opened = <Uri>[];
    final server = FakeMessageGateway(
      replies: [
        {
          ...messageJson('r1', 2, '', parentMessageId: 'm1', type: 'FILE'),
          'attachments': [
            {'name': '답글.pdf', 'size': 2048, 'mimeType': 'application/pdf'},
          ],
        },
      ],
    );
    await pumpThread(
      tester,
      server,
      FakeChatSocket(),
      openUrl: (url) async {
        opened.add(url);
        return true;
      },
    );

    await tester.tap(find.text('답글.pdf'));
    await tester.pumpAndSettle();

    expect(opened, [Uri.parse('https://files.test/reply.pdf')]);
  });

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
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );

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
