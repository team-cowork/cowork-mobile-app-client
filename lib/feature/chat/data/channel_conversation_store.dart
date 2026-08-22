import '../../profile/domain/profile_entity.dart';
import '../domain/chat_message.dart';
import '../domain/enums/chat_avatar_color.dart';

class ChannelConversationStore {
  ChannelConversationStore._();

  static final ChannelConversationStore instance = ChannelConversationStore._();

  String get channelName => '백엔드';

  String get channelDescription => '백엔드 API 개발 · PR/이슈 논의';

  List<ChatMessage> get messages => const [
    ChatMessage(
      id: 'm1',
      author: ProfileEntity(id: 101, name: 'junjuny', avatarInitial: '준'),
      avatarColor: ChatAvatarColor.blue,
      timestamp: '오늘 14:20',
      text: 'PR #2 재연결 로직 리뷰 부탁드려요. 네트워크 상태 감시 부분이 핵심입니다.',
    ),
    ChatMessage(
      id: 'm2',
      author: ProfileEntity(id: 102, name: '도윤', avatarInitial: '도'),
      avatarColor: ChatAvatarColor.green,
      timestamp: '오늘 14:22',
      text: '확인했어요. useEffect 의존성 배열에 socket 인스턴스가 빠진 것 같은데 한 번 봐주실래요?',
    ),
    ChatMessage(
      id: 'm3',
      author: ProfileEntity(id: 103, name: '서연', avatarInitial: '서'),
      avatarColor: ChatAvatarColor.amber,
      timestamp: '오늘 14:25',
      text: '방금 머지했습니다. CI 통과 확인했고 dev 서버에 반영했어요 🚀',
    ),
    ChatMessage(
      id: 'm4',
      author: ProfileEntity(id: 101, name: 'junjuny', avatarInitial: '준'),
      avatarColor: ChatAvatarColor.blue,
      timestamp: '오늘 14:30',
      text: '감사합니다! 그럼 이슈 #14 클로즈할게요.',
    ),
    ChatMessage(
      id: 'm5',
      author: ProfileEntity(id: 104, name: '민재', avatarInitial: '민'),
      avatarColor: ChatAvatarColor.red,
      timestamp: '오늘 14:41',
      text: '다음 스프린트 칸반에 백로그 카드 3개 추가해뒀어요. 확인 부탁!',
    ),
  ];
}
