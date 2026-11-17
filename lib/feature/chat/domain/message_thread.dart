import 'package:equatable/equatable.dart';

import 'chat_message.dart';

class MessageThread extends Equatable {
  const MessageThread({
    required this.channelName,
    required this.rootMessage,
    required this.replies,
    this.name,
    this.isArchived = false,
  });

  final String channelName;
  final ChatMessage rootMessage;

  /// 시간 오름차순. 오래된 답글이 앞에 온다.
  final List<ChatMessage> replies;

  /// 스레드에 붙인 이름. 이름을 붙인 적이 없으면 null.
  final String? name;

  /// 보관된 스레드인지.
  final bool isArchived;

  @override
  List<Object?> get props => [
    channelName,
    rootMessage,
    replies,
    name,
    isArchived,
  ];
}
