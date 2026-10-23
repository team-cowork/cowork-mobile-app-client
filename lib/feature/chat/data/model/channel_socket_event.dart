import 'package:json_annotation/json_annotation.dart';

import '../../../../network/chat_socket.dart';
import '../../domain/channel.dart';
import 'channel_view_type.dart';
import 'responses/channel_event_response.dart';

/// 채팅 홈이 반영할 소켓 이벤트.
sealed class ChannelSocketEvent {
  const ChannelSocketEvent();

  /// 홈과 관계없는 이벤트이거나 형식이 맞지 않으면 null.
  static ChannelSocketEvent? from(SocketEvent event) {
    final ChannelEventResponse payload;
    try {
      payload = ChannelEventResponse.fromJson(event.data);
    } on CheckedFromJsonException {
      return null;
    }

    final ChannelEventResponse(
      :channelId,
      :teamId,
      name: channelName,
      :viewType,
    ) = payload;
    return switch (event.name) {
      // 홈은 같은 id 의 채널을 통째로 바꾸므로, 이름이나 유형이 빠진 채 오면 기존 값을
      // 기본값으로 덮는다. 서버는 늘 다 보내지만, 빠져 오면 덮지 않고 버린다.
      'channel:created' || 'channel:updated'
          when channelId != null &&
              teamId != null &&
              channelName != null &&
              viewType != null =>
        ChannelUpserted(
          teamId: teamId,
          channel: Channel(
            id: '$channelId',
            name: channelName,
            type: channelTypeOf(viewType),
          ),
        ),
      'channel:deleted' || 'channel:access:revoked' when channelId != null =>
        ChannelRemoved('$channelId'),
      'team:access:revoked' when teamId != null => TeamAccessRevoked(teamId),
      _ => null,
    };
  }
}

/// 보이는 채널 목록 하나를 고치는 이벤트. 목록이 아직 없을 때 모아 뒀다가 반영한다.
sealed class ChannelListChange extends ChannelSocketEvent {
  const ChannelListChange();
}

/// 채널이 생겼거나 바뀌었다. (`channel:created` / `channel:updated`)
final class ChannelUpserted extends ChannelListChange {
  const ChannelUpserted({required this.teamId, required this.channel});

  final int teamId;
  final Channel channel;
}

/// 채널이 지워졌거나 더는 읽을 수 없다. (`channel:deleted` / `channel:access:revoked`)
///
/// 채널 목록 API 도 읽을 수 있는 채널만 주므로 둘 다 목록에서 뺀다.
final class ChannelRemoved extends ChannelListChange {
  const ChannelRemoved(this.channelId);

  final String channelId;
}

/// 내가 팀에서 빠졌다. (`team:access:revoked`)
final class TeamAccessRevoked extends ChannelSocketEvent {
  const TeamAccessRevoked(this.teamId);

  final int teamId;
}
