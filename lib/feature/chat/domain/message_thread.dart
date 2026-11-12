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

  /// 시간 오름차순. 오래된 답글이 앞에 온다.
  final List<ChatMessage> replies;

  @override
  List<Object?> get props => [channelName, rootMessage, replies];
}
