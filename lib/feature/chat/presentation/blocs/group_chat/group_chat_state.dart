part of 'group_chat_bloc.dart';

typedef ChannelMembersData = ({
  String channelName,
  List<ChannelMember> members,
});

/// 채널(단체채팅) 관련 화면들이 공유하는 상태.
///
/// 스레드 · 멤버 · 채널 설정은 각각 다른 화면에서 쓰지만 전부 "이 채널" 하나에 대한
/// 데이터라 [GroupChatBloc] 하나가 구획별로 나눠 들고 있는다. 채널 메시지는 서버와
/// 소켓을 쓰는 `ChannelMessageBloc` 이 따로 맡는다.
class GroupChatState extends Equatable {
  const GroupChatState({
    this.thread = const AsyncState.initial(),
    this.members = const AsyncState.initial(),
    this.settings = const AsyncState.initial(),
  });

  final AsyncState<MessageThread> thread;
  final AsyncState<ChannelMembersData> members;
  final AsyncState<ChannelSettings> settings;

  GroupChatState copyWith({
    AsyncState<MessageThread>? thread,
    AsyncState<ChannelMembersData>? members,
    AsyncState<ChannelSettings>? settings,
  }) => GroupChatState(
    thread: thread ?? this.thread,
    members: members ?? this.members,
    settings: settings ?? this.settings,
  );

  @override
  List<Object?> get props => [thread, members, settings];
}
