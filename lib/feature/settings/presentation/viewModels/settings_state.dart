part of 'settings_bloc.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  const factory SettingsState.initial() = SettingsInitial;
  const factory SettingsState.loading() = SettingsLoading;
  const factory SettingsState.success(Settings settings) = SettingsSuccess;
  const factory SettingsState.failure() = SettingsFailure;

  @override
  List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsSuccess extends SettingsState {
  const SettingsSuccess(this.settings);

  final Settings settings;

  @override
  List<Object?> get props => [settings];
}

final class SettingsFailure extends SettingsState {
  const SettingsFailure();
}
