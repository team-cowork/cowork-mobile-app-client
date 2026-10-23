part of 'channel_settings_bloc.dart';

sealed class ChannelSettingsEvent extends Equatable {
  const ChannelSettingsEvent();

  const factory ChannelSettingsEvent.requested() = ChannelSettingsRequested;

  const factory ChannelSettingsEvent.toggled(
    ChannelSettingsToggle toggle,
    bool value,
  ) = ChannelSettingsToggled;

  @override
  List<Object?> get props => [];
}

final class ChannelSettingsRequested extends ChannelSettingsEvent {
  const ChannelSettingsRequested();
}

final class ChannelSettingsToggled extends ChannelSettingsEvent {
  const ChannelSettingsToggled(this.toggle, this.value);

  final ChannelSettingsToggle toggle;
  final bool value;

  @override
  List<Object?> get props => [toggle, value];
}
