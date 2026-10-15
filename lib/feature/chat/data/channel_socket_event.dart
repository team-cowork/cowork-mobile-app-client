import '../../../network/chat_socket.dart';
import '../domain/channel.dart';
import 'channel_view_type.dart';

/// 채팅 홈이 반영할 소켓 이벤트.
///
/// 서버 payload 는 채널 id 를 `id` 가 아니라 `channelId` 로 보낸다(REST 응답과 다름).
sealed class ChannelSocketEvent {
  const ChannelSocketEvent();

  /// 홈과 관계없는 이벤트이거나 형식이 맞지 않으면 null.
  static ChannelSocketEvent? from(SocketEvent event) {
    final data = event.data;
    final channelId = data['channelId'];
    final teamId = data['teamId'];
    return switch (event.name) {
      'channel:created' || 'channel:updated'
          when channelId is int && teamId is int =>
        ChannelUpserted(
          teamId: teamId,
          channel: Channel(
            id: '$channelId',
            name: data['name'] as String? ?? '',
            type: channelTypeOf(data['viewType'] as String?),
          ),
        ),
      'channel:deleted' || 'channel:access:revoked' when channelId is int =>
        ChannelRemoved('$channelId'),
      'team:access:revoked' when teamId is int => TeamAccessRevoked(teamId),
      _ => null,
    };
  }
}

/// 채널이 생겼거나 바뀌었다. (`channel:created` / `channel:updated`)
final class ChannelUpserted extends ChannelSocketEvent {
  const ChannelUpserted({required this.teamId, required this.channel});

  final int teamId;
  final Channel channel;
}

/// 채널이 지워졌거나 더는 읽을 수 없다. (`channel:deleted` / `channel:access:revoked`)
///
/// 채널 목록 API 도 읽을 수 있는 채널만 주므로 둘 다 목록에서 뺀다.
final class ChannelRemoved extends ChannelSocketEvent {
  const ChannelRemoved(this.channelId);

  final String channelId;
}

/// 내가 팀에서 빠졌다. (`team:access:revoked`)
final class TeamAccessRevoked extends ChannelSocketEvent {
  const TeamAccessRevoked(this.teamId);

  final int teamId;
}
