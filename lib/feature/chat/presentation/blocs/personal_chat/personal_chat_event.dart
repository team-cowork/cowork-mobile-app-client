part of 'personal_chat_bloc.dart';

sealed class PersonalChatEvent extends Equatable {
  const PersonalChatEvent();

  /// 대화 목록을 처음 불러온다. 다시 시도에도 쓴다.
  const factory PersonalChatEvent.requested() = PersonalChatRequested;

  /// 화면을 바꾸지 않고 목록을 다시 읽는다. 새 메시지가 오거나 대화 화면에서 돌아왔을
  /// 때 쓴다.
  const factory PersonalChatEvent.refreshed() = PersonalChatRefreshed;

  /// 대화를 목록에서 숨긴다.
  const factory PersonalChatEvent.hidden(int channelId) = PersonalChatHidden;

  @override
  List<Object?> get props => [];
}

final class PersonalChatRequested extends PersonalChatEvent {
  const PersonalChatRequested();
}

final class PersonalChatRefreshed extends PersonalChatEvent {
  const PersonalChatRefreshed();
}

final class PersonalChatHidden extends PersonalChatEvent {
  const PersonalChatHidden(this.channelId);

  final int channelId;

  @override
  List<Object?> get props => [channelId];
}
