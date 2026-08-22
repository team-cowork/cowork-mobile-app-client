import '../../profile/domain/profile_entity.dart';
import '../domain/chat_message.dart';
import '../domain/enums/chat_avatar_color.dart';
import '../domain/message_thread.dart';

class ThreadStore {
  ThreadStore._();

  static final ThreadStore instance = ThreadStore._();

  MessageThread get thread => const MessageThread(
    channelName: '백엔드',
    rootMessage: ChatMessage(
      id: 'm2',
      author: ProfileEntity(id: 102, name: '도윤', avatarInitial: '도'),
      avatarColor: ChatAvatarColor.green,
      timestamp: '오늘 14:22',
      text: '확인했어요. useEffect 의존성 배열에 socket 인스턴스가 빠진 것 같은데 한 번 봐주실래요?',
    ),
    replies: [
      ChatMessage(
        id: 'r1',
        author: ProfileEntity(id: 101, name: 'junjuny', avatarInitial: '준'),
        avatarColor: ChatAvatarColor.blue,
        timestamp: '14:24',
        text: '아 맞네요, socket을 deps에 추가하고 cleanup에서 해제하도록 수정할게요.',
      ),
      ChatMessage(
        id: 'r2',
        author: ProfileEntity(id: 103, name: '서연', avatarInitial: '서'),
        avatarColor: ChatAvatarColor.amber,
        timestamp: '14:26',
        text: '그럼 재연결 핸들러도 useCallback으로 묶는 게 좋겠어요.',
      ),
      ChatMessage(
        id: 'r3',
        author: ProfileEntity(id: 102, name: '도윤', avatarInitial: '도'),
        avatarColor: ChatAvatarColor.green,
        timestamp: '14:28',
        text: '좋습니다 👍 PR에 코멘트 남겼어요.',
      ),
    ],
  );
}
