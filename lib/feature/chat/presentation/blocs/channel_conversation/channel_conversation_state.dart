part of 'channel_conversation_bloc.dart';

typedef ChannelConversationData = ({
  String name,
  String description,
  List<ChatMessage> messages,
});

typedef ChannelConversationState = AsyncState<ChannelConversationData>;
