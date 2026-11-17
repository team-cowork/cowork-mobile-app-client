part of 'channel_settings_bloc.dart';

typedef ChannelSettingsState = AsyncState<ChannelSettingsData>;

/// 채널 설정 화면이 그리는 데이터. 설정과, 화면이 한 번 알릴 변경 실패 사유를 든다.
final class ChannelSettingsData extends Equatable {
  const ChannelSettingsData({required this.settings, this.errorMessage});

  final ChannelSettings settings;

  /// 직전 변경이 실패한 사유. 화면이 한 번 보여 준다.
  final String? errorMessage;

  ChannelSettingsData withError(String message) =>
      ChannelSettingsData(settings: settings, errorMessage: message);

  @override
  List<Object?> get props => [settings, errorMessage];
}
