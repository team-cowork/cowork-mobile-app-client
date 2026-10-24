import 'package:cowork_app/feature/notifications/data/repositories/notification_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notification_test_stream.dart';

void main() {
  late FakeNotificationStream stream;
  late NotificationRepository repository;

  setUp(() {
    stream = FakeNotificationStream();
    repository = NotificationRepository(stream);
  });

  tearDown(() => repository.dispose());

  test('켜면 스트림을 열고, 받은 알림을 최신순으로 쌓는다', () async {
    repository.start();
    expect(stream.running, isTrue);

    stream
      ..push({'type': 'CHAT_MESSAGE', 'title': '첫 번째', 'channelId': 10})
      ..push({'type': 'MEMBER_INVITED', 'title': '두 번째', 'teamId': 3});
    await pumpEventQueue();

    expect([for (final n in repository.items) n.event.title], ['두 번째', '첫 번째']);
    expect(repository.items.last.event.channelId, 10);
    expect(repository.items.first.read, isFalse);
  });

  test('형식이 틀린 알림은 버린다', () async {
    repository.start();

    stream.push({'title': 3});
    await pumpEventQueue();

    expect(repository.items, isEmpty);
  });

  test('읽음과 모두 읽음을 반영하고 바뀌었다고 알린다', () async {
    repository.start();
    stream
      ..push({'title': '첫 번째'})
      ..push({'title': '두 번째'});
    await pumpEventQueue();
    var changes = 0;
    repository.changes.listen((_) => changes++);

    repository.markRead(repository.items.first.id);
    await pumpEventQueue();
    expect([for (final n in repository.items) n.read], [true, false]);

    repository.markAllRead();
    repository.markAllRead();
    await pumpEventQueue();
    expect([for (final n in repository.items) n.read], [true, true]);
    expect(changes, 2);
  });

  test('끄면 스트림을 닫고 받은 알림을 비운다', () async {
    repository.start();
    stream.push({'title': '로그아웃 전'});
    await pumpEventQueue();

    repository.stop();
    stream.push({'title': '로그아웃 뒤'});
    await pumpEventQueue();

    expect(stream.running, isFalse);
    expect(repository.items, isEmpty);
  });

  test('상한을 넘으면 오래된 알림부터 버린다', () async {
    repository.start();
    for (var i = 0; i <= NotificationRepository.maxItems; i++) {
      stream.push({'title': '알림 $i'});
    }
    await pumpEventQueue();

    expect(repository.items, hasLength(NotificationRepository.maxItems));
    expect(repository.items.last.event.title, '알림 1');
  });
}
