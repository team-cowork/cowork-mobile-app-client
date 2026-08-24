part of 'chat_bloc.dart';

/// 홈(채팅 목록) 화면에서 필요한 데이터.
typedef ChatHomeData = ({
  String workspaceName,
  List<WorkspaceShortcut> workspaceShortcuts,
  List<ChannelGroup> channelGroups,
});

/// 홈 화면 상태. 성공 시 [ChatHomeData]를 담는다.
typedef ChatState = AsyncState<ChatHomeData>;
