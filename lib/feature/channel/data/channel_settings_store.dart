import '../../../shared/domain/enums/chat_avatar_color.dart';
import '../../../shared/domain/profile_entity.dart';
import '../domain/channel_member.dart';
import '../domain/channel_settings.dart';
import '../domain/enums/channel_settings_toggle.dart';

class ChannelSettingsStore {
  ChannelSettingsStore._();

  static final ChannelSettingsStore instance = ChannelSettingsStore._();

  bool _isPrivate = false;
  bool _isMuted = false;

  static const _members = [
    ChannelMember(
      profile: ProfileEntity(id: 101, name: 'junjuny', avatarInitial: '준'),
      avatarColor: ChatAvatarColor.blue,
    ),
    ChannelMember(
      profile: ProfileEntity(id: 102, name: '도윤', avatarInitial: '도'),
      avatarColor: ChatAvatarColor.green,
    ),
    ChannelMember(
      profile: ProfileEntity(id: 103, name: '서연', avatarInitial: '서'),
      avatarColor: ChatAvatarColor.amber,
    ),
    ChannelMember(
      profile: ProfileEntity(id: 104, name: '민재', avatarInitial: '민'),
      avatarColor: ChatAvatarColor.red,
    ),
    ChannelMember(
      profile: ProfileEntity(id: 105, name: '지훈', avatarInitial: '지'),
      avatarColor: ChatAvatarColor.neutral,
    ),
  ];

  ChannelSettings get settings {
    return ChannelSettings(
      name: '백엔드',
      description: '백엔드 API 개발 · PR/이슈 논의',
      isPrivate: _isPrivate,
      notificationLabel: '모든 메시지',
      isMuted: _isMuted,
      memberPreview: _members.take(4).toList(),
      memberCount: _members.length,
    );
  }

  void updateToggle(ChannelSettingsToggle toggle, bool value) {
    switch (toggle) {
      case ChannelSettingsToggle.isPrivate:
        _isPrivate = value;
      case ChannelSettingsToggle.isMuted:
        _isMuted = value;
    }
  }
}
