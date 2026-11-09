import 'package:equatable/equatable.dart';

import 'chat_message.dart';

class MessageThread extends Equatable {
  const MessageThread({
    required this.channelName,
    required this.rootMessage,
    required this.replies,
    this.errorMessage,
  });

  final String channelName;
  final ChatMessage rootMessage;

  /// 오래된 것부터 최신 순.
  final List<ChatMessage> replies;

  /// 직전 답글 전송이 실패한 사유. 화면이 한 번 보여 준다.
  final String? errorMessage;

  MessageThread withError(String message) => MessageThread(
    channelName: channelName,
    rootMessage: rootMessage,
    replies: replies,
    errorMessage: message,
  );

  @override
  List<Object?> get props => [channelName, rootMessage, replies, errorMessage];
}
