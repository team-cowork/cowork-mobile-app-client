part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  /// 홈 화면 데이터 로드를 요청한다.
  const factory ChatEvent.requested() = ChatRequested;

  /// 보이는 목록을 그대로 둔 채 서버 목록으로 조용히 갈아끼운다.
  ///
  /// 다른 기기·사람이 만든 팀·채널을 반영하려고, 앱이 다시 앞으로 올 때 보낸다.
  const factory ChatEvent.refreshed() = ChatRefreshed;

  /// 단축 바에서 다른 팀을 골랐다.
  const factory ChatEvent.teamSelected(int teamId) = ChatTeamSelected;

  /// 팀 생성 시트가 서버에 팀을 만들었다.
  const factory ChatEvent.teamCreated(TeamSummaryResponse team) =
      ChatTeamCreated;

  /// 채널 생성 시트가 서버에 채널을 만들었다.
  const factory ChatEvent.channelAdded(Channel channel) = ChatChannelAdded;

  @override
  List<Object?> get props => [];
}

final class ChatRequested extends ChatEvent {
  const ChatRequested();
}

final class ChatRefreshed extends ChatEvent {
  const ChatRefreshed();
}

final class ChatTeamSelected extends ChatEvent {
  const ChatTeamSelected(this.teamId);

  final int teamId;

  @override
  List<Object?> get props => [teamId];
}

final class ChatTeamCreated extends ChatEvent {
  const ChatTeamCreated(this.team);

  final TeamSummaryResponse team;

  @override
  List<Object?> get props => [team];
}

final class ChatChannelAdded extends ChatEvent {
  const ChatChannelAdded(this.channel);

  final Channel channel;

  @override
  List<Object?> get props => [channel];
}
