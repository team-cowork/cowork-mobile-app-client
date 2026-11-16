part of 'channel_settings_bloc.dart';

sealed class ChannelSettingsEvent extends Equatable {
  const ChannelSettingsEvent();

  /// 설정을 처음 불러온다. 다시 시도에도 쓴다.
  const factory ChannelSettingsEvent.requested() = ChannelSettingsRequested;

  /// 채널 이름을 바꾼다. 앞뒤 공백을 떼고 비면 무시한다.
  const factory ChannelSettingsEvent.nameChanged(String name) =
      ChannelSettingsNameChanged;

  /// 채널 설명을 바꾼다. 비우는 것도 바꾸는 것이다.
  const factory ChannelSettingsEvent.descriptionChanged(String description) =
      ChannelSettingsDescriptionChanged;

  /// 비공개 채널 여부를 바꾼다.
  const factory ChannelSettingsEvent.privateToggled(bool value) =
      ChannelSettingsPrivateToggled;

  /// 이 채널의 알림 수준을 바꾼다. null 이면 정하지 않고 계정·팀 설정을 따른다.
  const factory ChannelSettingsEvent.notificationLevelChanged(
    NotificationLevel? level,
  ) = ChannelSettingsNotificationLevelChanged;

  /// 이 채널을 음소거하거나 푼다.
  const factory ChannelSettingsEvent.muteToggled(bool value) =
      ChannelSettingsMuteToggled;

  @override
  List<Object?> get props => [];
}

final class ChannelSettingsRequested extends ChannelSettingsEvent {
  const ChannelSettingsRequested();
}

final class ChannelSettingsNameChanged extends ChannelSettingsEvent {
  const ChannelSettingsNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class ChannelSettingsDescriptionChanged extends ChannelSettingsEvent {
  const ChannelSettingsDescriptionChanged(this.description);

  final String description;

  @override
  List<Object?> get props => [description];
}

final class ChannelSettingsPrivateToggled extends ChannelSettingsEvent {
  const ChannelSettingsPrivateToggled(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}

final class ChannelSettingsNotificationLevelChanged
    extends ChannelSettingsEvent {
  const ChannelSettingsNotificationLevelChanged(this.level);

  final NotificationLevel? level;

  @override
  List<Object?> get props => [level];
}

final class ChannelSettingsMuteToggled extends ChannelSettingsEvent {
  const ChannelSettingsMuteToggled(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}
