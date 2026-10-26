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

/// 소켓으로 홈에 반영할 이벤트가 왔다. 화면이 아니라 Bloc 이 스스로 넣는다.
final class _ChannelListSocketEventReceived extends ChannelListEvent {
  const _ChannelListSocketEventReceived(this.event);

  final ChannelSocketEvent event;

  @override
  List<Object?> get props => [event];
}
