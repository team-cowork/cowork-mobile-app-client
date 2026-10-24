import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../data/channel_members_store.dart';
import '../../../data/channel_settings_store.dart';
import '../../../data/thread_store.dart';
import '../../../domain/channel_member.dart';
import '../../../domain/channel_settings.dart';
import '../../../domain/enums/channel_settings_toggle.dart';
import '../../../domain/message_thread.dart';

part 'group_chat_event.dart';
part 'group_chat_state.dart';

class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  GroupChatBloc() : super(const GroupChatState()) {
    on<ThreadRequested>(_onLoadThread);
    on<MembersRequested>(_onLoadMembers);
    on<GroupChatSettingsRequested>(_onLoadSettings);
    on<GroupChatSettingsToggled>(_onToggleSettings);
  }

  void _onLoadThread(ThreadRequested event, Emitter<GroupChatState> emit) {
    emit(state.copyWith(thread: const AsyncState.loading()));
    try {
      emit(
        state.copyWith(thread: AsyncState.success(ThreadStore.instance.thread)),
      );
    } catch (_) {
      emit(state.copyWith(thread: const AsyncState.failure()));
    }
  }

  void _onLoadMembers(MembersRequested event, Emitter<GroupChatState> emit) {
    emit(state.copyWith(members: const AsyncState.loading()));
    try {
      final store = ChannelMembersStore.instance;
      emit(
        state.copyWith(
          members: AsyncState.success((
            channelName: store.channelName,
            members: store.members,
          )),
        ),
      );
    } catch (_) {
      emit(state.copyWith(members: const AsyncState.failure()));
    }
  }

  void _onLoadSettings(
    GroupChatSettingsRequested event,
    Emitter<GroupChatState> emit,
  ) {
    emit(state.copyWith(settings: const AsyncState.loading()));
    try {
      emit(
        state.copyWith(
          settings: AsyncState.success(ChannelSettingsStore.instance.settings),
        ),
      );
    } catch (_) {
      emit(state.copyWith(settings: const AsyncState.failure()));
    }
  }

  void _onToggleSettings(
    GroupChatSettingsToggled event,
    Emitter<GroupChatState> emit,
  ) {
    final settingsState = state.settings;
    if (settingsState is! AsyncSuccess<ChannelSettings>) return;

    ChannelSettingsStore.instance.updateToggle(event.toggle, event.value);

    final settings = settingsState.data;
    final updated = switch (event.toggle) {
      ChannelSettingsToggle.isPrivate => settings.copyWith(
        isPrivate: event.value,
      ),
      ChannelSettingsToggle.isMuted => settings.copyWith(isMuted: event.value),
    };
    emit(state.copyWith(settings: AsyncState.success(updated)));
  }
}
