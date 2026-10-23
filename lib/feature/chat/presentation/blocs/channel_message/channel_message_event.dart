part of 'channel_message_bloc.dart';

sealed class ChannelMessageEvent extends Equatable {
  const ChannelMessageEvent();

  /// 채널 머리와 최근 메시지를 불러온다.
  const factory ChannelMessageEvent.requested() = ChannelMessageRequested;

  /// 지금 보이는 것보다 이전 메시지를 불러온다.
  const factory ChannelMessageEvent.olderRequested() =
      ChannelMessageOlderRequested;

  @override
  List<Object?> get props => [];
}

final class ChannelMessageRequested extends ChannelMessageEvent {
  const ChannelMessageRequested();
}

final class ChannelMessageOlderRequested extends ChannelMessageEvent {
  const ChannelMessageOlderRequested();
}
