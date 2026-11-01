import '../../../../shared/utils/initial.dart';
import '../../domain/enums/avatar_color.dart';
import '../../domain/enums/notification_icon_type.dart';
import '../../domain/notification_item.dart';
import 'received_notification.dart';

/// 받은 알림을 화면 알림으로. 받은 시각은 [now] 기준 상대 표기한다.
///
/// 태스크 할당·GitHub 댓글은 아이콘으로, 나머지는 제목 첫 글자 아바타로 보인다.
NotificationItem notificationItemOf(
  ReceivedNotification notification, {
  DateTime? now,
}) {
  final event = notification.event;
  final icon = switch (event.type) {
    'PROJECT_TASK_ASSIGNED' => NotificationIconType.taskAssigned,
    'GITHUB_COMMENT_CREATED' => NotificationIconType.gitPush,
    _ => null,
  };
  final title = event.title.isEmpty ? '알림' : event.title;

  return NotificationItem(
    id: notification.id,
    title: title,
    description: event.body,
    time: notificationTimeOf(notification.receivedAt, now: now),
    isUnread: !notification.read,
    avatarInitial: icon == null ? initialOf(title) : null,
    avatarColor: icon == null ? _avatarColorOf(title) : null,
    icon: icon,
    channelId: event.channelId == 0 ? null : event.channelId,
    // 팀에서 빠졌다는 알림은 그 팀으로 갈 수 없다.
    teamId: event.teamId == 0 || event.type == 'MEMBER_REMOVED'
        ? null
        : event.teamId,
  );
}

/// `방금` / `5분 전` / `3시간 전` / `어제` / `3월 2일`.
String notificationTimeOf(DateTime receivedAt, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final elapsed = current.difference(receivedAt);
  if (elapsed.inMinutes < 1) return '방금';
  if (elapsed.inHours < 1) return '${elapsed.inMinutes}분 전';
  final days = DateTime(current.year, current.month, current.day)
      .difference(DateTime(receivedAt.year, receivedAt.month, receivedAt.day))
      .inDays;
  if (days == 0) return '${elapsed.inHours}시간 전';
  if (days == 1) return '어제';
  return '${receivedAt.month}월 ${receivedAt.day}일';
}

/// 같은 제목(팀·보낸 사람)이 늘 같은 색이 되도록 고른다.
AvatarColor _avatarColorOf(String title) =>
    AvatarColor.values[title.hashCode.abs() % AvatarColor.values.length];
