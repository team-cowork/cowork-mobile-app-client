part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  /// 설정 데이터 로드를 요청한다.
  const factory SettingsEvent.requested() = SettingsRequested;

  /// 토글 항목의 값을 변경한다.
  const factory SettingsEvent.toggled(SettingsToggle toggle, bool value) =
      SettingsToggled;

  @override
  List<Object?> get props => [];
}

final class SettingsRequested extends SettingsEvent {
  const SettingsRequested();
}

final class SettingsToggled extends SettingsEvent {
  const SettingsToggled(this.toggle, this.value);

  final SettingsToggle toggle;
  final bool value;

  @override
  List<Object?> get props => [toggle, value];
}
