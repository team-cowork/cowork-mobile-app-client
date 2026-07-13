import 'package:cowork_app/feature/settings/domain/enus/setting_toggle_enum.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/settings.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// 설정 화면 상태를 관리하는 Bloc.
///
/// 현재는 목(mock) 데이터를 반환한다. 실제 API 연동 시 [_onLoad]/[_onToggle] 내부만 교체하면 된다.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState.initial()) {
    on<SettingsRequested>(_onLoad);
    on<SettingsToggled>(_onToggle);
  }

  Future<void> _onLoad(
    SettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    try {
      // ponytail: 목 데이터. 실제 설정 API 연동 시 이 부분만 교체.
      const settings = Settings(
        linkedAccount: 'DataGSM',
        pushNotification: true,
        mentionOnly: false,
        darkMode: true,
        commitStreakPublic: true,
        version: '1.0.0',
      );
      emit(const SettingsState.success(settings));
    } catch (_) {
      emit(const SettingsState.failure());
    }
  }

  void _onToggle(SettingsToggled event, Emitter<SettingsState> emit) {
    final state = this.state;
    if (state is! SettingsSuccess) return;

    final settings = state.settings;
    final updated = switch (event.toggle) {
      SettingsToggle.pushNotification => settings.copyWith(
        pushNotification: event.value,
      ),
      SettingsToggle.mentionOnly => settings.copyWith(mentionOnly: event.value),
      SettingsToggle.darkMode => settings.copyWith(darkMode: event.value),
      SettingsToggle.commitStreakPublic => settings.copyWith(
        commitStreakPublic: event.value,
      ),
    };
    emit(SettingsState.success(updated));
  }
}
