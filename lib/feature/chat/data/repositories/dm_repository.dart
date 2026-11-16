import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../channel/data/model/responses/channel_response.dart';
import '../model/responses/dm_conversation_response.dart';

/// 1:1 대화(DM) 저장소.
///
/// 대화 목록은 chat 서비스에, DM 채널을 만드는 일은 channel 서비스에 있어 게이트웨이
/// prefix 가 다른 dio 둘을 쓴다. 대화 내용은 채널 메시지 API 를 그대로 쓴다.
class DmRepository {
  DmRepository(AuthRepository auth)
    : this.withDio(
        chat: createAuthedDio(ApiService.chat, auth),
        channel: createAuthedDio(ApiService.channel, auth),
      );

  DmRepository.withDio({required Dio chat, required Dio channel})
    : _chat = chat,
      _channel = channel;

  final Dio _chat;
  final Dio _channel;

  /// 내 대화 목록. 숨긴 대화는 빠지고 마지막 메시지가 최근인 대화가 앞이다.
  Future<List<DmConversationResponse>> fetchConversations() async => [
    for (final json in unwrapListPayload(
      (await _chat.get<String>('/chat/dms')).data ?? '',
    ))
      DmConversationResponse.fromJson(json),
  ];

  /// 대화를 목록에서 숨긴다. 상대가 새 메시지를 보내면 다시 나타난다.
  Future<void> hideConversation(int channelId) =>
      _chat.delete<String>('/chat/dms/$channelId');

  /// [targetUserId] 와의 DM 채널 id. 이미 대화 중이면 그 채널이다.
  Future<int> openConversation(int targetUserId) async {
    final channel = ChannelResponse.fromJson(
      unwrapPayload(
        (await _channel.post<String>(
              '/dms',
              data: {'targetUserId': targetUserId},
            )).data ??
            '',
      ),
    );
    return channel.id;
  }
}
