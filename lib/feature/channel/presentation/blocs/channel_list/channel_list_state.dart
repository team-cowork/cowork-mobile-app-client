part of 'channel_list_bloc.dart';

/// 홈 화면에 보일 팀과 채널 목록.
///
/// [teamId] 는 지금 보고 있는 팀. 속한 팀이 하나도 없으면 null 이고 나머지는 빈 값이다.
/// `isTeamOwner` 는 그 팀의 소유자인지다. 소유자는 팀을 나갈 수 없어 메뉴에서 뺀다.
/// `canInviteMembers` 는 그 팀에서 멤버를 초대할 권한(`manage_invites`)이 있는지다.
/// `canCreateChannels`·`canCreateProjects` 는 채널(`manage_channels`)·프로젝트
/// (`manage_projects`)를 만들 권한이 있는지다. 셋 다 권한을 못 읽었으면 true 다.
typedef ChannelListData = ({
  int? teamId,
  String workspaceName,
  bool isTeamOwner,
  bool canInviteMembers,
  bool canCreateChannels,
  bool canCreateProjects,
  List<WorkspaceShortcut> workspaceShortcuts,
  List<ChannelGroup> channelGroups,
});

/// 홈 화면 상태. 성공 시 [ChannelListData]를 담는다.
typedef ChannelListState = AsyncState<ChannelListData>;
