part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  /// 홈 화면 데이터 로드를 요청한다.
  const factory ChatEvent.requested() = ChatRequested;

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

/// 소켓으로 홈에 반영할 이벤트가 왔다. 화면이 아니라 Bloc 이 스스로 넣는다.
final class _ChatSocketEventReceived extends ChatEvent {
  const _ChatSocketEventReceived(this.event);

  final ChannelSocketEvent event;

  @override
  List<Object?> get props => [event];
}
