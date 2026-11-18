import 'dart:async';

import 'package:cowork_app/core/network/chat_socket.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/chat/presentation/views/channel_view.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:cowork_app/shared/utils/external_url.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../channel/chat_test_server.dart';
import 'channel_message_test_server.dart';

void main() {
  Future<void> pumpChannel(
    WidgetTester tester,
    FakeMessageGateway gateway, {
    String? focusMessageId,
    String? dmName,
    bool isDirect = false,
    FakeChatSocket? socket,
    UrlOpener? openUrl,
    FakeFilesServer? files,
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
              files: filesDio(files ?? FakeFilesServer()),
            ),
          ),
          RepositoryProvider.value(value: chatFileRepositoryOf(gateway)),
          RepositoryProvider.value(
            value: ProfileRepository.withDio(messageDio(gateway, 'user')),
          ),
          RepositoryProvider<ChatSocket>.value(
            value: socket ?? FakeChatSocket(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => ChannelView(
                  channelId: 10,
                  focusMessageId: focusMessageId,
                  dmName: dmName,
                  isDirect: isDirect,
                  openUrl: openUrl ?? (_) async => true,
                ),
              ),
              GoRoute(
                path: '/chat/channel/:channelId/thread',
                builder: (_, state) => Text(
                  '스레드 ${state.pathParameters['channelId']} '
                  '${state.uri.queryParameters['parentMessageId']}',
                ),
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

  testWidgets('메시지를 누르면 이 채널에서 그 메시지의 스레드로 간다', (tester) async {
    await pumpChannel(tester, FakeMessageGateway(messages: [otherMessage]));

    await tester.tap(messageText('남의 메시지'));
    await tester.pumpAndSettle();

    expect(find.text('스레드 10 m1'), findsOneWidget);
  });

  testWidgets('메시지 수정 시트를 열면 입력창에 바로 포커스가 간다', (tester) async {
    await pumpChannel(
      tester,
      FakeMessageGateway(messages: [myMessage, otherMessage]),
    );

    await tester.longPress(messageText('내 메시지'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('메시지 수정'));
    await tester.pumpAndSettle();

    // 입력창에 포커스가 있으면 키보드(입력 연결)가 열려 있다.
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('파일만 있는 메시지는 빈 본문 자리를 만들지 않는다', (tester) async {
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
          messageJson('m0', 3, '본문이 있는 메시지'),
        ],
      ),
    );

    // 본문이 있는 메시지만 마크다운 본문을 그린다.
    expect(
      find.byWidgetPredicate((w) => w.runtimeType.toString() == 'MarkdownBody'),
      findsOneWidget,
    );
    expect(find.text('기획서.pdf'), findsOneWidget);

    // 첨부 카드는 아바타 높이만큼 내려가지 않고 머리줄 바로 아래에 붙는다.
    final gap =
        tester.getTopLeft(find.byType(CoworkAttachmentCard)).dy -
        tester.getBottomLeft(find.textContaining('도윤 ·')).dy;
    expect(gap, AppSpacing.s8);
  });

  testWidgets('DM 대화는 머리에 상대 이름을 보이고 채널 이름·설명은 숨긴다', (tester) async {
    await pumpChannel(
      tester,
      FakeMessageGateway(messages: [otherMessage]),
      dmName: '서연',
    );

    expect(find.text('서연'), findsOneWidget);
    expect(find.text('백엔드'), findsNothing);
    expect(find.text('API 논의'), findsNothing);
  });

  testWidgets('상대 이름을 모르는 DM 대화는 머리에 다이렉트 메시지를 보인다', (tester) async {
    await pumpChannel(
      tester,
      FakeMessageGateway(messages: [otherMessage]),
      isDirect: true,
    );

    expect(find.text('다이렉트 메시지'), findsOneWidget);
    expect(find.text('백엔드'), findsNothing);
    expect(find.text('API 논의'), findsNothing);
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

  group('이미지 첨부는', () {
    FakeMessageGateway withImage({String mimeType = 'image/png'}) =>
        FakeMessageGateway(
          messages: [
            {
              ...messageJson('img1', 2, '', type: 'FILE'),
              'attachments': [
                {'name': '화면.png', 'size': 2048, 'mimeType': mimeType},
              ],
            },
          ],
        );

    testWidgets('카드 대신 그림으로 보인다', (tester) async {
      await pumpChannel(tester, withImage());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(CoworkAttachmentCard), findsNothing);
    });

    testWidgets('그릴 수 없는 형식은 카드로 보인다', (tester) async {
      await pumpChannel(tester, withImage(mimeType: 'image/svg+xml'));

      expect(find.byType(Image), findsNothing);
      expect(find.byType(CoworkAttachmentCard), findsOneWidget);
    });

    testWidgets('받지 못하면 눌러서 다시 받는다', (tester) async {
      final files = FakeFilesServer()..failing = true;
      await pumpChannel(tester, withImage(), files: files);
      await tester.pumpAndSettle();
      expect(find.textContaining('눌러서 다시 시도'), findsOneWidget);

      files.failing = false;
      await tester.tap(find.textContaining('눌러서 다시 시도'));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(files.requests, hasLength(2));
    });

    testWidgets('누르면 임시 주소로 크게 볼 수 있게 연다', (tester) async {
      final opened = <Uri>[];
      await pumpChannel(
        tester,
        withImage(),
        openUrl: (url) async {
          opened.add(url);
          return true;
        },
      );
      await tester.pumpAndSettle();
      // 그림이 풀려야 크기가 생겨 누를 수 있다.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();

      await tester.tap(find.byType(Image));
      await tester.pumpAndSettle();

      expect(opened, [Uri.parse('https://files.test/img1.png')]);
    });
  });

  group('첨부파일을 누르면', () {
    FakeMessageGateway withAttachment() => FakeMessageGateway(
      messages: [
        {
          ...messageJson('m1', 2, '', type: 'FILE'),
          'attachments': [
            {'name': '기획서.pdf', 'size': 2048, 'mimeType': 'application/pdf'},
          ],
        },
      ],
    );

    testWidgets('임시 주소를 새로 받아 바로 연다', (tester) async {
      final opened = <Uri>[];
      final gateway = withAttachment();
      await pumpChannel(
        tester,
        gateway,
        openUrl: (url) async {
          opened.add(url);
          return true;
        },
      );

      await tester.tap(find.text('기획서.pdf'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('기획서.pdf'));
      await tester.pumpAndSettle();

      expect(opened, [
        Uri.parse('https://files.test/a.pdf'),
        Uri.parse('https://files.test/a.pdf'),
      ]);
      // 주소는 저장하지 않고 누를 때마다 새로 받는다.
      expect(
        gateway.calls.where((c) => c.endsWith('/download-url')),
        hasLength(2),
      );
    });

    testWidgets('주소를 받지 못하면 안내하고 열지 않는다', (tester) async {
      final opened = <Uri>[];
      final gateway = withAttachment()
        ..failing =
            'GET /chat/chat/channels/10/messages/m1/attachments/0/download-url';
      await pumpChannel(
        tester,
        gateway,
        openUrl: (url) async {
          opened.add(url);
          return true;
        },
      );

      await tester.tap(find.text('기획서.pdf'));
      await tester.pumpAndSettle();

      expect(opened, isEmpty);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('여는 중에 다시 누르면 주소를 또 받지 않는다', (tester) async {
      final gate = Completer<bool>();
      final gateway = withAttachment();
      await pumpChannel(tester, gateway, openUrl: (_) => gate.future);

      await tester.tap(find.text('기획서.pdf'));
      await tester.pump();
      await tester.tap(find.text('기획서.pdf'));
      gate.complete(true);
      await tester.pumpAndSettle();

      expect(
        gateway.calls.where((c) => c.endsWith('/download-url')),
        hasLength(1),
      );
    });

    testWidgets('열 수 있는 앱이 없으면 안내한다', (tester) async {
      await pumpChannel(tester, withAttachment(), openUrl: (_) async => false);

      await tester.tap(find.text('기획서.pdf'));
      await tester.pumpAndSettle();

      expect(find.text('파일을 열 수 있는 앱이 없어요.'), findsOneWidget);
    });
  });

  group('검색한 메시지로 열면', () {
    /// m1(가장 오래됨) ~ m200(가장 최근). 서버처럼 최신순이다.
    FakeMessageGateway twoHundred() => FakeMessageGateway(
      messages: [for (var i = 200; i > 0; i--) messageJson('m$i', 2, '메시지 $i')],
    );

    /// 화면에 실제로 보이는 메시지. 목록이 미리 만들어 둔 화면 밖 줄은 뺀다.
    Finder visible(String text) => messageText(text).hitTestable();

    testWidgets('그 메시지가 화면에 보인다', (tester) async {
      await pumpChannel(tester, twoHundred(), focusMessageId: 'm100');

      expect(visible('메시지 100'), findsOneWidget);
      expect(visible('메시지 150'), findsNothing);
    });

    testWidgets('그 메시지를 못 찾으면 최근 대화로 열었다고 알린다', (tester) async {
      await pumpChannel(tester, twoHundred(), focusMessageId: 'gone');

      expect(find.text('메시지를 찾을 수 없어 최근 대화를 보여 드려요.'), findsOneWidget);
      expect(visible('메시지 200'), findsOneWidget);
    });

    testWidgets('메시지를 고르지 않으면 최근 메시지가 아래에 보인다', (tester) async {
      await pumpChannel(tester, twoHundred());

      expect(visible('메시지 200'), findsOneWidget);
      expect(visible('메시지 100'), findsNothing);
    });

    testWidgets('그 메시지를 지워도 보던 자리에 머문다', (tester) async {
      final gateway = FakeMessageGateway(
        messages: [
          for (var i = 200; i > 0; i--)
            messageJson('m$i', i == 100 ? 1 : 2, '메시지 $i'),
        ],
      );
      await pumpChannel(tester, gateway, focusMessageId: 'm100');
      final newerBefore = tester.getTopLeft(messageText('메시지 101'));

      await tester.longPress(messageText('메시지 100'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('메시지 삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();

      expect(visible('메시지 100'), findsNothing);
      expect(visible('메시지 99'), findsOneWidget);
      expect(visible('메시지 101'), findsOneWidget);
      expect(
        tester.getTopLeft(messageText('메시지 101')),
        newerBefore,
        reason: '지운 줄만 빠지고 그 아래 최근 메시지는 움직이지 않는다',
      );
    });

    testWidgets('최근 메시지까지 내리면 새 메시지가 아래 끝에 보인다', (tester) async {
      final socket = FakeChatSocket();
      await pumpChannel(
        tester,
        twoHundred(),
        socket: socket,
        focusMessageId: 'm190',
      );
      expect(visible('메시지 190'), findsOneWidget);

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, -2000),
        3000,
      );
      await tester.pumpAndSettle();
      expect(visible('메시지 200'), findsOneWidget);

      socket.push('message', messageJson('m201', 2, '방금 온 메시지'));
      await tester.pumpAndSettle();

      expect(visible('방금 온 메시지'), findsOneWidget);
    });

    testWidgets('채널 처음 근처를 열면 채널 첫 메시지가 위 끝에 붙고 그 위로 더 올라가지 않는다', (
      tester,
    ) async {
      await pumpChannel(tester, twoHundred(), focusMessageId: 'm2');
      final listTop = tester.getTopLeft(find.byType(CustomScrollView)).dy;

      expect(visible('메시지 2'), findsOneWidget);
      final firstTop = tester.getTopLeft(messageText('메시지 1')).dy;
      expect(firstTop - listTop, lessThan(40), reason: '첫 메시지 위가 비지 않는다');

      // 더 오래된 쪽으로 끌어도 첫 메시지는 위 끝에 머문다.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(messageText('메시지 1')).dy, firstTop);
    });

    testWidgets('메시지가 화면보다 적으면 고른 메시지로 열어도 최근 메시지가 아래 끝에 있다', (tester) async {
      final gateway = FakeMessageGateway(
        messages: [for (var i = 3; i > 0; i--) messageJson('m$i', 2, '메시지 $i')],
      );
      await pumpChannel(tester, gateway, focusMessageId: 'm1');
      final listBottom = tester.getBottomLeft(find.byType(CustomScrollView)).dy;

      final lastBottom = tester.getBottomLeft(messageText('메시지 3')).dy;
      expect(
        listBottom - lastBottom,
        lessThan(40),
        reason: '최근 메시지 아래가 비지 않는다',
      );
    });
  });
}
