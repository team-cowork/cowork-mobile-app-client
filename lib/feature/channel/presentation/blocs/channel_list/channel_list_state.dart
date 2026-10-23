part of 'channel_list_bloc.dart';

/// 홈 화면에 보일 팀과 채널 목록.
///
/// [teamId] 는 지금 보고 있는 팀. 속한 팀이 하나도 없으면 null 이고 나머지는 빈 값이다.
typedef ChannelListData = ({
  int? teamId,
  String workspaceName,
  List<WorkspaceShortcut> workspaceShortcuts,
  List<ChannelGroup> channelGroups,
});

/// 홈 화면 상태. 성공 시 [ChannelListData]를 담는다.
typedef ChannelListState = AsyncState<ChannelListData>;
