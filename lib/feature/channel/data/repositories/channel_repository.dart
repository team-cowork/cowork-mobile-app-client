import 'package:dio/dio.dart';

import '../../../../network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../../domain/channel.dart';
import '../model/requests/create_channel_request.dart';
import '../model/responses/channel_response.dart';

/// channel 서비스의 채널 저장소.
class ChannelRepository {
  ChannelRepository(AuthRepository auth)
    : this.withDio(createAuthedDio(ApiService.channel, auth));

  ChannelRepository.withDio(this._dio);

  final Dio _dio;

  /// 팀에서 내가 볼 수 있는 채널을 서버 순서(position) 그대로.
  Future<List<Channel>> fetchChannels(int teamId) async => [
    for (final json in unwrapListPayload(
      (await _dio.get<String>('/teams/$teamId/channels')).data ?? '',
    ))
      ChannelResponse.fromJson(json).toChannel(),
  ];

  /// 채널을 만들고 서버가 저장한 채널을 돌려준다.
  Future<Channel> createChannel(CreateChannelRequest request) async =>
      ChannelResponse.fromJson(
        unwrapPayload(
          (await _dio.post<String>('/channels', data: request.toJson())).data ??
              '',
        ),
      ).toChannel();
}
