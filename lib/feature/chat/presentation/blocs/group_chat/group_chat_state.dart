part of 'group_chat_bloc.dart';

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
