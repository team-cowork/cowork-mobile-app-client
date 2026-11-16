import 'package:cowork_app/core/network/chat_socket.dart';
import 'package:cowork_app/feature/chat/data/repositories/dm_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/chat/presentation/views/dm_list_view.dart';
import 'package:cowork_app/feature/profile/data/profile_store.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../channel/chat_test_server.dart';
import 'dm_test_server.dart';

void main() {
  setUp(() => ProfileStore.instance.currentUserId = 1);
  tearDown(() => ProfileStore.instance.currentUserId = null);

  Future<void> pumpDmList(WidgetTester tester, FakeDmGateway gateway) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DmRepository>.value(
            value: dmRepositoryOf(gateway),
          ),
          RepositoryProvider<MessageRepository>.value(
            value: dmMessageRepositoryOf(gateway),
          ),
          RepositoryProvider<ChatSocket>.value(value: FakeChatSocket()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: GoRouter(
            routes: [
              GoRoute(path: '/', builder: (_, _) => const DmListView()),
              GoRoute(
                path: '/chat/channel/:channelId',
                builder: (_, state) => Text(
                  '대화 ${state.pathParameters['channelId']} '
                  '${state.uri.queryParameters['dmName']}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  FakeDmGateway gateway() => FakeDmGateway(
    conversations: [
      dmJson(11, 2, content: '안녕하세요', unreadCount: 2),
      dmJson(12, 3, content: '확인했어요', authorId: 1),
    ],
  );

  testWidgets('대화를 상대 이름과 마지막 메시지, 읽지 않은 수와 함께 보여 준다', (tester) async {
    await pumpDmList(tester, gateway());

    expect(find.text('서연'), findsOneWidget);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('도윤'), findsOneWidget);
    expect(find.text('나: 확인했어요'), findsOneWidget);
  });

  testWidgets('대화가 없으면 안내를 보여 준다', (tester) async {
    await pumpDmList(tester, FakeDmGateway());

    expect(find.text('아직 대화가 없어요'), findsOneWidget);
  });

  testWidgets('대화를 누르면 그 DM 채널의 대화 화면으로 간다', (tester) async {
    await pumpDmList(tester, gateway());

    await tester.tap(find.text('서연'));
    await tester.pumpAndSettle();

    expect(find.text('대화 11 서연'), findsOneWidget);
  });

  testWidgets('길게 눌러 숨기기를 확인하면 목록에서 빠지고 DELETE 를 보낸다', (tester) async {
    final server = gateway();
    await pumpDmList(tester, server);

    await tester.longPress(find.text('서연'));
    await tester.pumpAndSettle();
    expect(find.text('서연님과의 대화를 숨길까요?'), findsOneWidget);
    await tester.tap(find.text('숨기기'));
    await tester.pumpAndSettle();

    expect(server.calls, contains('DELETE /chat/chat/dms/11'));
    expect(find.text('서연'), findsNothing);
    expect(find.text('도윤'), findsOneWidget);
  });

  testWidgets('숨기기를 취소하면 그대로 둔다', (tester) async {
    final server = gateway();
    await pumpDmList(tester, server);

    await tester.longPress(find.text('서연'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(server.calls, isNot(contains(startsWith('DELETE'))));
    expect(find.text('서연'), findsOneWidget);
  });

  testWidgets('숨기기가 실패하면 대화가 돌아오고 사유를 알린다', (tester) async {
    final server = gateway();
    await pumpDmList(tester, server);
    server.failing = 'DELETE /chat/chat/dms/11';

    await tester.longPress(find.text('서연'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('숨기기'));
    await tester.pumpAndSettle();

    expect(find.text('서연'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('불러오지 못하면 에러 화면에서 다시 시도할 수 있다', (tester) async {
    final server = gateway()..failing = 'GET /chat/chat/dms';
    await pumpDmList(tester, server);

    expect(find.text('DM 목록을 불러오지 못했어요'), findsOneWidget);

    server.failing = null;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('서연'), findsOneWidget);
  });
}
