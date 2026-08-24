import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../data/channel_settings_store.dart';
import '../../domain/channel_settings.dart';
import '../../domain/enums/channel_settings_toggle.dart';

part 'channel_settings_event.dart';

typedef ChannelSettingsState = AsyncState<ChannelSettings>;

class ChannelSettingsBloc
    extends Bloc<ChannelSettingsEvent, ChannelSettingsState> {
  ChannelSettingsBloc() : super(const ChannelSettingsState.initial()) {
    on<ChannelSettingsRequested>(_onLoad);
    on<ChannelSettingsToggled>(_onToggle);
  }

  void _onLoad(
    ChannelSettingsRequested event,
    Emitter<ChannelSettingsState> emit,
  ) {
    emit(const ChannelSettingsState.loading());
    try {
      emit(ChannelSettingsState.success(ChannelSettingsStore.instance.settings));
    } catch (_) {
      emit(const ChannelSettingsState.failure());
    }
  }

  void _onToggle(
    ChannelSettingsToggled event,
    Emitter<ChannelSettingsState> emit,
  ) {
    final state = this.state;
    if (state is! AsyncSuccess<ChannelSettings>) return;

    final settings = state.data;
    final updated = switch (event.toggle) {
      ChannelSettingsToggle.isPrivate => settings.copyWith(
        isPrivate: event.value,
      ),
      ChannelSettingsToggle.isMuted => settings.copyWith(isMuted: event.value),
    };
    emit(ChannelSettingsState.success(updated));
  }
}
