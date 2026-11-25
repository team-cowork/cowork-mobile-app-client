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

  /// 프로젝트 생성 시트가 서버에 프로젝트를 만들었다.
  const factory ChannelListEvent.projectAdded(ProjectSummaryResponse project) =
      ChannelListProjectAdded;

  /// 내가 [teamId] 팀에서 나갔다(팀 나가기 성공). 보던 팀이면 다른 팀으로 옮긴다.
  const factory ChannelListEvent.teamLeft(int teamId) = ChannelListTeamLeft;

  /// 팀 설정에서 돌아왔다. 팀 이름이 바뀌었거나 팀이 지워졌을 수 있다.
  const factory ChannelListEvent.teamsRefreshed() = ChannelListTeamsRefreshed;

  /// 홈이 화면에 보이게 됐거나([visible]) 다른 화면·탭에 가려졌다.
  /// 보이는 동안만 안 읽은 수를 주기적으로 다시 읽는다.
  const factory ChannelListEvent.visibilityChanged({required bool visible}) =
      ChannelListVisibilityChanged;

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

final class ChannelListProjectAdded extends ChannelListEvent {
  const ChannelListProjectAdded(this.project);

  final ProjectSummaryResponse project;

  @override
  List<Object?> get props => [project];
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

final class ChannelListVisibilityChanged extends ChannelListEvent {
  const ChannelListVisibilityChanged({required this.visible});

  final bool visible;

  @override
  List<Object?> get props => [visible];
}

/// 앱이 화면 앞으로 왔거나([foreground]) 뒤로 갔다. 화면이 아니라 Bloc 이 스스로 넣는다.
final class _ChannelListForegroundChanged extends ChannelListEvent {
  const _ChannelListForegroundChanged({required this.foreground});

  final bool foreground;

  @override
  List<Object?> get props => [foreground];
}

/// 안 읽은 수를 다시 읽을 때가 됐다. 화면이 아니라 Bloc 이 스스로 넣는다.
final class _ChannelListUnreadPolled extends ChannelListEvent {
  const _ChannelListUnreadPolled();
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
