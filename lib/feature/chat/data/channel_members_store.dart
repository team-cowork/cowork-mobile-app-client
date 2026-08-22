import '../../profile/domain/profile_entity.dart';
import '../domain/channel_member.dart';
import '../domain/enums/chat_avatar_color.dart';

class ChannelMembersStore {
  ChannelMembersStore._();

  static final ChannelMembersStore instance = ChannelMembersStore._();

  String get channelName => '백엔드';

  List<ChannelMember> get members => const [
    ChannelMember(
      profile: ProfileEntity(id: 101, name: 'junjuny', avatarInitial: '준'),
      role: '백엔드 개발자',
      avatarColor: ChatAvatarColor.blue,
      isOnline: true,
      isOwner: true,
    ),
    ChannelMember(
      profile: ProfileEntity(id: 102, name: '도윤', avatarInitial: '도'),
      role: '백엔드 개발자',
      avatarColor: ChatAvatarColor.green,
      isOnline: true,
    ),
    ChannelMember(
      profile: ProfileEntity(id: 103, name: '서연', avatarInitial: '서'),
      role: '프론트엔드 개발자',
      avatarColor: ChatAvatarColor.amber,
      isOnline: true,
    ),
    ChannelMember(
      profile: ProfileEntity(id: 104, name: '민재', avatarInitial: '민'),
      role: 'PM · 기획',
      avatarColor: ChatAvatarColor.red,
      isOnline: true,
    ),
    ChannelMember(
      profile: ProfileEntity(id: 105, name: '지훈', avatarInitial: '지'),
      role: '디자이너',
      avatarColor: ChatAvatarColor.neutral,
      isOnline: false,
    ),
  ];
}
