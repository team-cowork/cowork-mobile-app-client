import 'package:dio/dio.dart';

import '../../../network/dio_client.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/channel.dart';
import 'channel_request.dart';
import 'channel_response.dart';
import 'team_request.dart';
import 'team_response.dart';

/// 채팅 홈의 팀·채널 저장소.
///
/// 팀 목록은 team, 채널은 channel 서비스에 있어서 게이트웨이 prefix 가 다른 dio
/// 둘을 쓴다. 단계마다 메서드를 나눠 둔 건 호출부가 어느 단계에서 실패했는지
/// 구분해 보여줄 수 있게 하려는 것이다.
class ChatRepository {
  ChatRepository(AuthRepository auth)
    : this.withDio(
        team: createAuthedDio(ApiService.team, auth),
        channel: createAuthedDio(ApiService.channel, auth),
      );

  ChatRepository.withDio({required Dio team, required Dio channel})
    : _team = team,
      _channel = channel;

  final Dio _team;
  final Dio _channel;

  /// 내가 속한 팀 목록.
  Future<List<TeamSummaryResponse>> fetchMyTeams() async => [
    for (final json in unwrapListPayload(
      (await _team.get<String>('/teams')).data ?? '',
    ))
      TeamSummaryResponse.fromJson(json),
  ];

  /// 팀을 만들고 서버가 저장한 팀을 돌려준다. 만든 사람이 소유자가 된다.
  Future<TeamSummaryResponse> createTeam(CreateTeamRequest request) async =>
      TeamSummaryResponse.fromJson(
        unwrapPayload(
          (await _team.post<String>('/teams', data: request.toJson())).data ??
              '',
        ),
      );

  /// 팀에서 내가 볼 수 있는 채널을 서버 순서(position) 그대로.
  Future<List<Channel>> fetchChannels(int teamId) async => [
    for (final json in unwrapListPayload(
      (await _channel.get<String>('/teams/$teamId/channels')).data ?? '',
    ))
      ChannelResponse.fromJson(json).toChannel(),
  ];

  /// 채널을 만들고 서버가 저장한 채널을 돌려준다.
  Future<Channel> createChannel(CreateChannelRequest request) async =>
      ChannelResponse.fromJson(
        unwrapPayload(
          (await _channel.post<String>(
                '/channels',
                data: request.toJson(),
              )).data ??
              '',
        ),
      ).toChannel();
}
