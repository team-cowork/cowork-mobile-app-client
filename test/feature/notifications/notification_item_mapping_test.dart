import 'package:cowork_app/feature/notifications/data/model/notification_item_mapping.dart';
import 'package:cowork_app/feature/notifications/data/model/received_notification.dart';
import 'package:cowork_app/feature/notifications/data/model/responses/notification_event_response.dart';
import 'package:cowork_app/feature/notifications/domain/enums/notification_icon_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 24, 18);

  ReceivedNotification received(
    NotificationEventResponse event, {
    DateTime? at,
  }) => ReceivedNotification(id: 'n0', event: event, receivedAt: at ?? now);

  test('받은 지 얼마나 됐는지 적는다', () {
    expect(notificationTimeOf(now, now: now), '방금');
    expect(
      notificationTimeOf(now.subtract(const Duration(minutes: 5)), now: now),
      '5분 전',
    );
    expect(
      notificationTimeOf(now.subtract(const Duration(hours: 3)), now: now),
      '3시간 전',
    );
    expect(notificationTimeOf(DateTime(2026, 10, 23, 23), now: now), '어제');
    expect(notificationTimeOf(DateTime(2026, 10, 2, 9), now: now), '10월 2일');
  });

  test('채팅 알림은 제목 첫 글자 아바타와 이동할 채널을 싣는다', () {
    final item = notificationItemOf(
      received(
        const NotificationEventResponse(
          type: 'CHAT_MESSAGE',
          title: '코워크 · #백엔드',
          body: '도윤: 리뷰 부탁드려요',
          channelId: 10,
          teamId: 3,
        ),
      ),
      now: now,
    );

    expect(item.avatarInitial, '코');
    expect(item.icon, isNull);
    expect(item.description, '도윤: 리뷰 부탁드려요');
    expect(item.channelId, 10);
    expect(item.teamId, 3);
    expect(item.isUnread, isTrue);
  });

  test('태스크 할당과 GitHub 댓글은 아이콘으로, 없는 id 는 null 로 둔다', () {
    final task = notificationItemOf(
      received(
        const NotificationEventResponse(
          type: 'PROJECT_TASK_ASSIGNED',
          title: '태스크 할당',
        ),
      ),
      now: now,
    );
    final comment = notificationItemOf(
      received(
        const NotificationEventResponse(
          type: 'GITHUB_COMMENT_CREATED',
          title: 'PR 댓글',
        ),
      ),
      now: now,
    );

    expect(task.icon, NotificationIconType.taskAssigned);
    expect(task.avatarInitial, isNull);
    expect(task.channelId, isNull);
    expect(task.teamId, isNull);
    expect(comment.icon, NotificationIconType.gitPush);
  });

  test('제목이 비어 있으면 알림으로 적는다', () {
    final item = notificationItemOf(
      received(const NotificationEventResponse()),
      now: now,
    );

    expect(item.title, '알림');
    expect(item.avatarInitial, '알');
  });

  test('팀에서 빠졌다는 알림은 이동할 팀을 싣지 않는다', () {
    final item = notificationItemOf(
      received(
        const NotificationEventResponse(
          type: 'MEMBER_REMOVED',
          title: '팀 멤버 제거',
          teamId: 3,
        ),
      ),
      now: now,
    );

    expect(item.teamId, isNull);
  });
}
