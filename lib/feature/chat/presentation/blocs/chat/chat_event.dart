part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  /// 홈 화면 데이터 로드를 요청한다.
  const factory ChatEvent.requested() = ChatRequested;

  /// 단축 바에서 다른 팀을 골랐다.
  const factory ChatEvent.teamSelected(int teamId) = ChatTeamSelected;

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
