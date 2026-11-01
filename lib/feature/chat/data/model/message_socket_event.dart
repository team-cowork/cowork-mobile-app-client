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
      'channel:deleted' when data['channelId'] is int => ChannelAccessLost(
        channelId: data['channelId'] as int,
        reason: ChannelAccessLostReason.deleted,
      ),
      'channel:access:revoked' when data['channelId'] is int =>
        ChannelAccessLost(
          channelId: data['channelId'] as int,
          reason: ChannelAccessLostReason.revoked,
        ),
      'team:access:revoked' when data['teamId'] is int => ChannelAccessLost(
        teamId: data['teamId'] as int,
        reason: ChannelAccessLostReason.leftTeam,
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

enum ChannelAccessLostReason { deleted, revoked, leftTeam }

/// 채널을 더 볼 수 없게 됐다. (`channel:deleted` / `channel:access:revoked` /
/// `team:access:revoked`)
///
/// 채널 이벤트는 [channelId], 팀 이벤트는 [teamId] 만 있다. 받는 쪽이 보고 있는
/// 채널·팀과 맞는지 본다.
final class ChannelAccessLost extends MessageSocketEvent {
  const ChannelAccessLost({this.channelId, this.teamId, required this.reason});

  final int? channelId;
  final int? teamId;
  final ChannelAccessLostReason reason;
}
