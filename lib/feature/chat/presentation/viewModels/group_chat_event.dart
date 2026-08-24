part of 'group_chat_bloc.dart';

sealed class GroupChatEvent extends Equatable {
  const GroupChatEvent();

  const factory GroupChatEvent.conversationRequested() = ConversationRequested;

  const factory GroupChatEvent.threadRequested() = ThreadRequested;

  const factory GroupChatEvent.membersRequested() = MembersRequested;

  const factory GroupChatEvent.settingsRequested() = GroupChatSettingsRequested;

  const factory GroupChatEvent.settingsToggled(
    ChannelSettingsToggle toggle,
    bool value,
  ) = GroupChatSettingsToggled;

  @override
  List<Object?> get props => [];
}

final class ConversationRequested extends GroupChatEvent {
  const ConversationRequested();
}

final class ThreadRequested extends GroupChatEvent {
  const ThreadRequested();
}

final class MembersRequested extends GroupChatEvent {
  const MembersRequested();
}

final class GroupChatSettingsRequested extends GroupChatEvent {
  const GroupChatSettingsRequested();
}

final class GroupChatSettingsToggled extends GroupChatEvent {
  const GroupChatSettingsToggled(this.toggle, this.value);

  final ChannelSettingsToggle toggle;
  final bool value;

  @override
  List<Object?> get props => [toggle, value];
}
