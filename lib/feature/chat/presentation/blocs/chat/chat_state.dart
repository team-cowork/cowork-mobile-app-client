part of 'chat_bloc.dart';

/// 홈(채팅 목록) 화면에서 필요한 데이터.
///
/// [teamId] 는 지금 보고 있는 팀. 속한 팀이 하나도 없으면 null 이고 나머지는 빈 값이다.
typedef ChatHomeData = ({
  int? teamId,
  String workspaceName,
  List<WorkspaceShortcut> workspaceShortcuts,
  List<ChannelGroup> channelGroups,
});

/// 홈 화면 상태. 성공 시 [ChatHomeData]를 담는다.
typedef ChatState = AsyncState<ChatHomeData>;
