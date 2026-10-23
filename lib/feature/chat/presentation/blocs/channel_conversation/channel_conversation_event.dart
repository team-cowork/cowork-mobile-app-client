part of 'channel_conversation_bloc.dart';

sealed class ChannelConversationEvent extends Equatable {
  const ChannelConversationEvent();

  const factory ChannelConversationEvent.requested() =
      ChannelConversationRequested;

  @override
  List<Object?> get props => [];
}

final class ChannelConversationRequested extends ChannelConversationEvent {
  const ChannelConversationRequested();
}
