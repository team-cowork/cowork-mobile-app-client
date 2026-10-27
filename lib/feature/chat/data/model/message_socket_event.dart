import 'package:json_annotation/json_annotation.dart';

import '../../../../core/network/chat_socket.dart';
import 'responses/message_response.dart';

/// 채널 대화 화면이 반영할 소켓 이벤트.
sealed class MessageSocketEvent {
  const MessageSocketEvent();

  /// 대화와 관계없는 이벤트이거나 형식이 맞지 않으면 null.
  static MessageSocketEvent? from(SocketEvent event) {
    final data = event.data;
    return switch (event.name) {
      'message' => _received(data),
      'message:edited'
          when data['messageId'] is String && data['content'] is String =>
        MessageEdited(
          messageId: data['messageId'] as String,
          content: data['content'] as String,
        ),
      'message:deleted' when data['messageId'] is String => MessageDeleted(
        data['messageId'] as String,
      ),
      _ => null,
    };
  }

  static MessageReceived? _received(Map<String, dynamic> data) {
    try {
      return MessageReceived(MessageResponse.fromJson(data));
    } on CheckedFromJsonException {
      return null;
    }
  }
}

/// 새 메시지가 저장됐다. (`message`)
final class MessageReceived extends MessageSocketEvent {
  const MessageReceived(this.message);

  final MessageResponse message;
}

/// 메시지 내용이 바뀌었다. (`message:edited`)
///
/// payload 에 채널 id 가 없다. 채널 방에 들어가 있을 때만 오므로 id 로만 찾는다.
final class MessageEdited extends MessageSocketEvent {
  const MessageEdited({required this.messageId, required this.content});

  final String messageId;
  final String content;
}

/// 메시지가 지워졌다. (`message:deleted`)
final class MessageDeleted extends MessageSocketEvent {
  const MessageDeleted(this.messageId);

  final String messageId;
}
