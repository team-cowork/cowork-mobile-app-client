import 'package:cowork_app/feature/notifications/data/repositories/notification_repository.dart';
import 'package:cowork_app/feature/notifications/presentation/views/notifications_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'notification_test_stream.dart';

void main() {
  late FakeNotificationStream stream;
  late NotificationRepository repository;

  // 위젯 테스트의 가짜 시간 안에서 스트림이 돌도록 테스트 본문에서 만든다.
  void startRepository() {
    stream = FakeNotificationStream();
    repository = NotificationRepository(stream)..start();
    addTearDown(repository.dispose);
  }

  Future<void> pumpNotifications(WidgetTester tester) async {
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: repository,
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: GoRouter(
            routes: [
              GoRoute(path: '/', builder: (_, _) => const NotificationsView()),
              GoRoute(
                path: '/chat/channel',
                builder: (_, state) => Text('채널 ${state.extra}'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('받은 알림이 없으면 빈 화면을 보여 준다', (tester) async {
    startRepository();
    await pumpNotifications(tester);

    expect(find.text('아직 받은 알림이 없어요'), findsOneWidget);
  });

  testWidgets('화면을 연 동안 온 알림이 위에 붙는다', (tester) async {
    startRepository();
    stream.push({'type': 'CHAT_MESSAGE', 'title': '먼저 온 알림'});
    await pumpNotifications(tester);

    stream.push({'type': 'CHAT_MESSAGE', 'title': '나중에 온 알림'});
    await tester.pumpAndSettle();

    final first = tester.getTopLeft(find.text('나중에 온 알림')).dy;
    final second = tester.getTopLeft(find.text('먼저 온 알림')).dy;
    expect(first, lessThan(second));
  });

  testWidgets('채널 알림을 누르면 읽음으로 바꾸고 그 채널로 간다', (tester) async {
    startRepository();
    stream.push({
      'type': 'CHAT_MESSAGE',
      'title': '코워크 · #백엔드',
      'body': '리뷰 부탁드려요',
      'channelId': 10,
    });
    await pumpNotifications(tester);

    await tester.tap(find.text('코워크 · #백엔드'));
    await tester.pumpAndSettle();

    expect(find.text('채널 10'), findsOneWidget);
    expect(repository.items.single.read, isTrue);
  });

  testWidgets('채널도 팀도 없는 알림은 읽음으로만 바꾼다', (tester) async {
    startRepository();
    stream.push({'type': 'PROJECT_TASK_ASSIGNED', 'title': '태스크 할당'});
    await pumpNotifications(tester);

    await tester.tap(find.text('태스크 할당'));
    await tester.pumpAndSettle();

    expect(find.text('태스크 할당'), findsOneWidget);
    expect(repository.items.single.read, isTrue);
  });

  testWidgets('모두 읽음을 누르면 전부 읽음이 된다', (tester) async {
    startRepository();
    stream
      ..push({'title': '첫 번째'})
      ..push({'title': '두 번째'});
    await pumpNotifications(tester);

    await tester.tap(find.text('모두 읽음'));
    await tester.pumpAndSettle();

    expect([for (final n in repository.items) n.read], [true, true]);
  });
}
