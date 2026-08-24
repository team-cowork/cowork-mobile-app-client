part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  /// 홈 화면 데이터 로드를 요청한다.
  const factory ChatEvent.requested() = ChatRequested;

  @override
  List<Object?> get props => [];
}

final class ChatRequested extends ChatEvent {
  const ChatRequested();
}
