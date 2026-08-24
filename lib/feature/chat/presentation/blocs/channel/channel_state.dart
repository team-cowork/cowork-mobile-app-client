part of 'channel_bloc.dart';

typedef ChannelConversationData = ({
  String name,
  String description,
  List<ChatMessage> messages,
});

typedef ChannelState = AsyncState<ChannelConversationData>;
