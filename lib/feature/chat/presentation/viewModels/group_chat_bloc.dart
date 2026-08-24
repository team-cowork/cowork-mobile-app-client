import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../data/channel_conversation_store.dart';
import '../../data/channel_members_store.dart';
import '../../data/channel_settings_store.dart';
import '../../data/thread_store.dart';
import '../../domain/channel_member.dart';
import '../../domain/channel_settings.dart';
import '../../domain/chat_message.dart';
import '../../domain/enums/channel_settings_toggle.dart';
import '../../domain/message_thread.dart';

part 'group_chat_event.dart';

typedef ChannelConversationData = ({
  String name,
  String description,
  List<ChatMessage> messages,
});

typedef ChannelMembersData = ({String channelName, List<ChannelMember> members});

/// 채널(단체채팅) 관련 화면들이 공유하는 상태.
///
/// 채널 메시지 · 스레드 · 멤버 · 채널 설정은 각각 다른 화면에서 쓰지만 전부 "이 채널"
/// 하나에 대한 데이터라 [GroupChatBloc] 하나가 구획별로 나눠 들고 있는다.
class GroupChatState extends Equatable {
  const GroupChatState({
    this.conversation = const AsyncState.initial(),
    this.thread = const AsyncState.initial(),
    this.members = const AsyncState.initial(),
    this.settings = const AsyncState.initial(),
  });

  final AsyncState<ChannelConversationData> conversation;
  final AsyncState<MessageThread> thread;
  final AsyncState<ChannelMembersData> members;
  final AsyncState<ChannelSettings> settings;

  GroupChatState copyWith({
    AsyncState<ChannelConversationData>? conversation,
    AsyncState<MessageThread>? thread,
    AsyncState<ChannelMembersData>? members,
    AsyncState<ChannelSettings>? settings,
  }) => GroupChatState(
    conversation: conversation ?? this.conversation,
    thread: thread ?? this.thread,
    members: members ?? this.members,
    settings: settings ?? this.settings,
  );

  @override
  List<Object?> get props => [conversation, thread, members, settings];
}

class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  GroupChatBloc() : super(const GroupChatState()) {
    on<ConversationRequested>(_onLoadConversation);
    on<ThreadRequested>(_onLoadThread);
    on<MembersRequested>(_onLoadMembers);
    on<GroupChatSettingsRequested>(_onLoadSettings);
    on<GroupChatSettingsToggled>(_onToggleSettings);
  }

  void _onLoadConversation(
    ConversationRequested event,
    Emitter<GroupChatState> emit,
  ) {
    emit(state.copyWith(conversation: const AsyncState.loading()));
    try {
      final store = ChannelConversationStore.instance;
      emit(
        state.copyWith(
          conversation: AsyncState.success((
            name: store.channelName,
            description: store.channelDescription,
            messages: store.messages,
          )),
        ),
      );
    } catch (_) {
      emit(state.copyWith(conversation: const AsyncState.failure()));
    }
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
