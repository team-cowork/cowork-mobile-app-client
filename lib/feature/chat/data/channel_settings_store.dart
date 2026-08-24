import '../domain/channel_settings.dart';
import 'channel_members_store.dart';

class ChannelSettingsStore {
  ChannelSettingsStore._();

  static final ChannelSettingsStore instance = ChannelSettingsStore._();

  ChannelSettings get settings {
    final members = ChannelMembersStore.instance.members;

    return ChannelSettings(
      name: '백엔드',
      description: '백엔드 API 개발 · PR/이슈 논의',
      isPrivate: false,
      notificationLabel: '모든 메시지',
      isMuted: false,
      memberPreview: members.take(4).toList(),
      memberCount: members.length,
    );
  }
}
