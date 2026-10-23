import 'package:json_annotation/json_annotation.dart';

import '../../../../network/chat_socket.dart';
import 'responses/message_response.dart';

/// 채널 대화 화면이 반영할 소켓 이벤트.
sealed class MessageSocketEvent {
  const MessageSocketEvent();

  /// 대화와 관계없는 이벤트이거나 형식이 맞지 않으면 null.
  static MessageSocketEvent? from(SocketEvent event) {
    final data = event.data;
    return switch (event.name) {
      'message' => _received(data),
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
