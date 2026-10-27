import 'package:equatable/equatable.dart';

import 'chat_message.dart';

class MessageThread extends Equatable {
  const MessageThread({
    required this.channelName,
    required this.rootMessage,
    required this.replies,
  });

  final String channelName;
  final ChatMessage rootMessage;
  final List<ChatMessage> replies;

  @override
  List<Object?> get props => [channelName, rootMessage, replies];
}
