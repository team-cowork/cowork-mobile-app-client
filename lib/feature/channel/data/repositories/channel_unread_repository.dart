import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../model/responses/channel_unread_response.dart';

/// 채널별 안 읽은 메시지 수 저장소.
///
/// 채널 목록은 channel 서비스에, 안 읽은 수는 chat 서비스에 있다. 게이트웨이 prefix 가
/// 달라 [ChannelRepository] 와 나눈다. 읽음 처리(`POST /chat/channels/{id}/read`)는
/// 채널 화면이 `MessageRepository` 로 보낸다.
class ChannelUnreadRepository {
  ChannelUnreadRepository(AuthRepository auth)
    : this.withDio(createAuthedDio(ApiService.chat, auth));

  ChannelUnreadRepository.withDio(this._chat);

  final Dio _chat;

  /// [teamId] 팀에서 내가 읽을 수 있는 채널별 안 읽은 수. 키는 채널 id 다.
  ///
  /// 서버가 주지 않은 채널은 안 읽은 메시지가 없는 것으로 본다.
  Future<Map<String, int>> fetchTeamUnread(int teamId) async {
    final body = (await _chat.get<String>('/chat/teams/$teamId/unread')).data;
    final unread = unwrapListPayload(
      body ?? '',
    ).map(ChannelUnreadResponse.fromJson);
    return {
      for (final channel in unread) '${channel.channelId}': channel.unreadCount,
    };
  }
}
