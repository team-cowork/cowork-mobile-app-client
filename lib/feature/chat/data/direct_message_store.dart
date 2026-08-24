import '../../profile/domain/profile_entity.dart';
import '../domain/direct_message_preview.dart';
import '../domain/dm_presence_entry.dart';
import '../domain/enums/chat_avatar_color.dart';
import '../domain/enums/dm_presence.dart';

class DirectMessageStore {
  DirectMessageStore._();

  static final DirectMessageStore instance = DirectMessageStore._();

  List<DmPresenceEntry> get onlineStrip => const [
    DmPresenceEntry(
      profile: ProfileEntity(id: 103, name: '서연', avatarInitial: '서'),
      avatarColor: ChatAvatarColor.amber,
      presence: DmPresence.online,
    ),
    DmPresenceEntry(
      profile: ProfileEntity(id: 102, name: '도윤', avatarInitial: '도'),
      avatarColor: ChatAvatarColor.green,
      presence: DmPresence.online,
    ),
    DmPresenceEntry(
      profile: ProfileEntity(id: 106, name: '태오', avatarInitial: '태'),
      avatarColor: ChatAvatarColor.red,
      presence: DmPresence.online,
    ),
    DmPresenceEntry(
      profile: ProfileEntity(id: 107, name: '하람', avatarInitial: '하'),
      avatarColor: ChatAvatarColor.blue,
      presence: DmPresence.idle,
    ),
  ];

  List<DirectMessagePreview> get pinned => const [
    DirectMessagePreview(
      profile: ProfileEntity(id: 103, name: '서연', avatarInitial: '서'),
      avatarColor: ChatAvatarColor.amber,
      presence: DmPresence.online,
      lastMessage: '입력 중…',
      timestamp: '14:28',
      isPinned: true,
      isTyping: true,
    ),
    DirectMessagePreview(
      profile: ProfileEntity(id: 102, name: '도윤', avatarInitial: '도'),
      avatarColor: ChatAvatarColor.green,
      presence: DmPresence.online,
      lastMessage: 'PR #2 머지했습니다. 확인 부탁드려요',
      timestamp: '어제',
      isPinned: true,
    ),
  ];

  List<DirectMessagePreview> get recent => const [
    DirectMessagePreview(
      profile: ProfileEntity(id: 104, name: '민재', avatarInitial: '민'),
      avatarColor: ChatAvatarColor.red,
      presence: DmPresence.offline,
      lastMessage: '다음 스프린트 백로그 카드 3개 추가해뒀어요',
      timestamp: '13:02',
      unreadCount: 2,
    ),
    DirectMessagePreview(
      profile: ProfileEntity(id: 107, name: '하람', avatarInitial: '하'),
      avatarColor: ChatAvatarColor.blue,
      presence: DmPresence.idle,
      lastMessage: '나: 회의록 초안 공유드립니다',
      timestamp: '어제',
    ),
    DirectMessagePreview(
      profile: ProfileEntity(id: 109, name: '지호', avatarInitial: '지'),
      avatarColor: ChatAvatarColor.amber,
      presence: DmPresence.offline,
      lastMessage: '네 확인했습니다!',
      timestamp: '어제',
    ),
    DirectMessagePreview(
      profile: ProfileEntity(id: 110, name: '유진', avatarInitial: '유'),
      avatarColor: ChatAvatarColor.green,
      presence: DmPresence.offline,
      lastMessage: '다음 주에 뵐게요',
      timestamp: '화요일',
      isMuted: true,
    ),
    DirectMessagePreview(
      profile: ProfileEntity(id: 106, name: '태오', avatarInitial: '태'),
      avatarColor: ChatAvatarColor.red,
      presence: DmPresence.online,
      lastMessage: 'Figma 링크 하나만 보내주실 수 있나요?',
      timestamp: '월요일',
    ),
  ];
}
