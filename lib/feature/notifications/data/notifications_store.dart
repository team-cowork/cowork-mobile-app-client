import '../domain/enums/avatar_color.dart';
import '../domain/enums/notification_icon_type.dart';
import '../domain/notification_item.dart';

class NotificationsStore {
  NotificationsStore._();

  static final NotificationsStore instance = NotificationsStore._();

  List<NotificationItem> get items => const [
    NotificationItem(
      id: 'mention-minjae',
      title: '민재님이 회원님을 멘션했어요',
      description: '#백엔드 · "백로그 카드 3개 추가해뒀어요. 확인 부탁!"',
      time: '방금',
      isUnread: true,
      avatarInitial: '민',
      avatarColor: AvatarColor.red,
    ),
    NotificationItem(
      id: 'reply-seoyeon',
      title: '서연님이 스레드에 답글을 남겼어요',
      description: '재연결 로직 스레드 · "useCallback으로 묶는 게…"',
      time: '5분 전',
      isUnread: true,
      avatarInitial: '서',
      avatarColor: AvatarColor.amber,
    ),
    NotificationItem(
      id: 'issue-assigned-14',
      title: '이슈 #14가 회원님에게 할당됐어요',
      description: '음성 채널 인원 제한 설정 UI · 계획됨',
      time: '1시간 전',
      isUnread: false,
      icon: NotificationIconType.taskAssigned,
    ),
    NotificationItem(
      id: 'pr-review-doyoon',
      title: '도윤님이 PR #2에 리뷰를 남겼어요',
      description: '재연결 로직 · 변경 요청 1건',
      time: '1시간 전',
      isUnread: false,
      avatarInitial: '도',
      avatarColor: AvatarColor.green,
    ),
    NotificationItem(
      id: 'github-webhook-push',
      title: 'github-webhook',
      description: 'main 브랜치에 커밋 3개가 푸시됐어요',
      time: '2시간 전',
      isUnread: false,
      icon: NotificationIconType.gitPush,
    ),
  ];
}
