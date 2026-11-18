part of 'channel_list_bloc.dart';

sealed class ChannelListEvent extends Equatable {
  const ChannelListEvent();

  /// 홈 화면 데이터 로드를 요청한다.
  const factory ChannelListEvent.requested() = ChannelListRequested;

  /// 단축 바에서 다른 팀을 골랐다.
  const factory ChannelListEvent.teamSelected(int teamId) =
      ChannelListTeamSelected;

  /// 팀 생성 시트가 서버에 팀을 만들었다.
  const factory ChannelListEvent.teamCreated(TeamSummaryResponse team) =
      ChannelListTeamCreated;

  /// 채널 생성 시트가 서버에 채널을 만들었다.
  const factory ChannelListEvent.channelAdded(Channel channel) =
      ChannelListChannelAdded;

  /// 내가 [teamId] 팀에서 나갔다(팀 나가기 성공). 보던 팀이면 다른 팀으로 옮긴다.
  const factory ChannelListEvent.teamLeft(int teamId) = ChannelListTeamLeft;

  /// 팀 설정에서 돌아왔다. 팀 이름이 바뀌었거나 팀이 지워졌을 수 있다.
  const factory ChannelListEvent.teamsRefreshed() = ChannelListTeamsRefreshed;

  @override
  List<Object?> get props => [];
}

final class ChannelListRequested extends ChannelListEvent {
  const ChannelListRequested();
}

final class ChannelListTeamSelected extends ChannelListEvent {
  const ChannelListTeamSelected(this.teamId);

  final int teamId;

  @override
  List<Object?> get props => [teamId];
}

final class ChannelListTeamCreated extends ChannelListEvent {
  const ChannelListTeamCreated(this.team);

  final TeamSummaryResponse team;

  @override
  List<Object?> get props => [team];
}

final class ChannelListChannelAdded extends ChannelListEvent {
  const ChannelListChannelAdded(this.channel);

  final Channel channel;

  @override
  List<Object?> get props => [channel];
}

final class ChannelListTeamLeft extends ChannelListEvent {
  const ChannelListTeamLeft(this.teamId);

  final int teamId;

  @override
  List<Object?> get props => [teamId];
}

final class ChannelListTeamsRefreshed extends ChannelListEvent {
  const ChannelListTeamsRefreshed();
}

/// 소켓으로 홈에 반영할 이벤트가 왔다. 화면이 아니라 Bloc 이 스스로 넣는다.
final class _ChannelListSocketEventReceived extends ChannelListEvent {
  const _ChannelListSocketEventReceived(this.event);

  final ChannelSocketEvent event;

  @override
  List<Object?> get props => [event];
}

/// 소켓이 끊김 복구 없이 다시 붙었다. 화면이 아니라 Bloc 이 스스로 넣는다.
final class _ChannelListReconnected extends ChannelListEvent {
  const _ChannelListReconnected();
}

/// 다른 사람이 나를 [teamId] 팀에 넣었다. 화면이 아니라 Bloc 이 스스로 넣는다.
final class _ChannelListTeamInvited extends ChannelListEvent {
  const _ChannelListTeamInvited(this.teamId);

  final int teamId;

  @override
  List<Object?> get props => [teamId];
}
