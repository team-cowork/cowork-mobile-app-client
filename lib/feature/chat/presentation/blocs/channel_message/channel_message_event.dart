part of 'channel_message_bloc.dart';

sealed class ChannelMessageEvent extends Equatable {
  const ChannelMessageEvent();

  /// 채널 머리와 최근 메시지를 불러온다.
  const factory ChannelMessageEvent.requested() = ChannelMessageRequested;

  /// 지금 보이는 것보다 이전 메시지를 불러온다.
  const factory ChannelMessageEvent.olderRequested() =
      ChannelMessageOlderRequested;

  /// 입력한 메시지를 보낸다.
  const factory ChannelMessageEvent.sent(String text) = ChannelMessageSent;

  /// 내 메시지 내용을 고친다.
  const factory ChannelMessageEvent.edited(String messageId, String text) =
      ChannelMessageEdited;

  /// 내 메시지를 지운다.
  const factory ChannelMessageEvent.deleted(String messageId) =
      ChannelMessageDeleted;

  @override
  List<Object?> get props => [];
}

final class ChannelMessageRequested extends ChannelMessageEvent {
  const ChannelMessageRequested();
}

final class ChannelMessageOlderRequested extends ChannelMessageEvent {
  const ChannelMessageOlderRequested();
}

final class ChannelMessageSent extends ChannelMessageEvent {
  const ChannelMessageSent(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class ChannelMessageEdited extends ChannelMessageEvent {
  const ChannelMessageEdited(this.messageId, this.text);

  final String messageId;
  final String text;

  @override
  List<Object?> get props => [messageId, text];
}

final class ChannelMessageDeleted extends ChannelMessageEvent {
  const ChannelMessageDeleted(this.messageId);

  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

/// 소켓으로 대화에 반영할 이벤트가 왔다. 화면이 아니라 Bloc 이 스스로 넣는다.
final class _ChannelMessageSocketEventReceived extends ChannelMessageEvent {
  const _ChannelMessageSocketEventReceived(this.event);

  final MessageSocketEvent event;

  @override
  List<Object?> get props => [event];
}

/// 이름을 몰랐던 작성자의 이름을 받아 왔다. Bloc 이 스스로 넣는다.
final class _ChannelMessageAuthorsResolved extends ChannelMessageEvent {
  const _ChannelMessageAuthorsResolved(this.authors);

  final List<ProfileEntity> authors;

  @override
  List<Object?> get props => [authors];
}

/// 보낸 메시지가 기다린 시간 안에 소켓으로 오지 않았다. Bloc 이 스스로 넣는다.
final class _ChannelMessageConfirmTimedOut extends ChannelMessageEvent {
  const _ChannelMessageConfirmTimedOut(this.clientMessageId);

  final String clientMessageId;

  @override
  List<Object?> get props => [clientMessageId];
}

/// 소켓이 끊김 복구 없이 다시 붙었다. Bloc 이 스스로 넣는다.
final class _ChannelMessageResynced extends ChannelMessageEvent {
  const _ChannelMessageResynced();
}
