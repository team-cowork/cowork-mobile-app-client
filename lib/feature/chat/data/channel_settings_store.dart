import '../domain/channel_settings.dart';
import '../domain/enums/channel_settings_toggle.dart';
import 'channel_members_store.dart';

class ChannelSettingsStore {
  ChannelSettingsStore._();

  static final ChannelSettingsStore instance = ChannelSettingsStore._();

  bool _isPrivate = false;
  bool _isMuted = false;

  ChannelSettings get settings {
    final members = ChannelMembersStore.instance.members;

    return ChannelSettings(
      name: '백엔드',
      description: '백엔드 API 개발 · PR/이슈 논의',
      isPrivate: _isPrivate,
      notificationLabel: '모든 메시지',
      isMuted: _isMuted,
      memberPreview: members.take(4).toList(),
      memberCount: members.length,
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
