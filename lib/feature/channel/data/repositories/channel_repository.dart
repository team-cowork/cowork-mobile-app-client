import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../../domain/channel.dart';
import '../model/requests/create_channel_request.dart';
import '../model/requests/create_thread_request.dart';
import '../model/requests/update_thread_request.dart';
import '../model/requests/update_channel_request.dart';
import '../model/responses/channel_member_response.dart';
import '../model/responses/channel_response.dart';
import '../model/responses/thread_response.dart';

/// 채널 화면 머리에 쓰는 채널 정보. [teamId] 는 DM 채널이면 null.
typedef ChannelHeader = ({String name, String description, int? teamId});

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

  /// 채널 하나의 이름·설명과 속한 팀. 채널 화면 머리에 쓴다.
  Future<ChannelHeader> fetchChannelHeader(int channelId) async {
    final channel = ChannelResponse.fromJson(
      unwrapPayload(
        (await _dio.get<String>('/channels/$channelId')).data ?? '',
      ),
    );
    return (
      name: channel.name,
      description: channel.description ?? '',
      teamId: channel.teamId,
    );
  }

  /// 채널 하나의 응답 그대로. 채널 설정 화면이 이름·설명·공개 여부를 읽을 때 쓴다.
  Future<ChannelResponse> fetchChannel(int channelId) async =>
      ChannelResponse.fromJson(
        unwrapPayload(
          (await _dio.get<String>('/channels/$channelId')).data ?? '',
        ),
      );

  /// 채널의 스레드 한 쪽. 보관된 것도 포함한다. [page] 는 0 부터 센다.
  Future<List<ThreadResponse>> fetchThreads(
    int channelId, {
    int page = 0,
  }) async {
    final content = unwrapPayload(
      (await _dio.get<String>(
            '/channels/$channelId/threads',
            queryParameters: {
              'includeArchived': true,
              'size': _threadPageSize,
              'page': page,
            },
          )).data ??
          '',
    )['content'];
    if (content is! List) return const [];
    return [
      for (final json in content.whereType<Map<String, dynamic>>())
        ThreadResponse.fromJson(json),
    ];
  }

  /// [parentMessageId] 메시지에 붙은 스레드. 만든 적이 없으면 null.
  ///
  /// 부모 메시지로 바로 찾는 API 는 없고 서버가 한 쪽에 [_threadPageSize] 개까지만 줘서,
  /// 찾을 때까지 쪽을 넘겨 읽는다.
  Future<ThreadResponse?> fetchThread(
    int channelId,
    String parentMessageId,
  ) async {
    final seen = <int>{};
    for (var page = 0; ; page++) {
      final threads = await fetchThreads(channelId, page: page);
      for (final thread in threads) {
        if (thread.parentMessageId == parentMessageId) return thread;
      }
      // 마지막 쪽이거나, 서버가 쪽을 무시해 같은 목록을 되풀이하면 그만 읽는다.
      final unseen = threads.where((thread) => seen.add(thread.id)).length;
      if (threads.length < _threadPageSize || unseen == 0) return null;
    }
  }

  /// [request.parentMessageId] 메시지에 이름을 붙여 스레드를 만든다.
  Future<ThreadResponse> createThread(
    int channelId,
    CreateThreadRequest request,
  ) async => ThreadResponse.fromJson(
    unwrapPayload(
      (await _dio.post<String>(
            '/channels/$channelId/threads',
            data: request.toJson(),
          )).data ??
          '',
    ),
  );

  /// 스레드의 이름·보관 여부를 바꾸고 서버가 저장한 스레드를 돌려준다.
  Future<ThreadResponse> updateThread(
    int channelId,
    int threadId,
    UpdateThreadRequest request,
  ) async => ThreadResponse.fromJson(
    unwrapPayload(
      (await _dio.patch<String>(
            '/channels/$channelId/threads/$threadId',
            data: request.toJson(),
          )).data ??
          '',
    ),
  );

  static const _threadPageSize = 100;

  /// 채널의 이름·설명·공개 여부를 바꾸고 서버가 저장한 채널을 돌려준다.
  Future<ChannelResponse> updateChannel(
    int channelId,
    UpdateChannelRequest request,
  ) async => ChannelResponse.fromJson(
    unwrapPayload(
      (await _dio.patch<String>(
            '/channels/$channelId',
            data: request.toJson(),
          )).data ??
          '',
    ),
  );

  /// 채널을 읽을 수 있는 사용자. 서버가 사용자 id 만 줘서 이름은 따로 채운다.
  Future<List<ChannelMemberResponse>> fetchMembers(int channelId) async => [
    for (final json in unwrapListPayload(
      (await _dio.get<String>('/channels/$channelId/members')).data ?? '',
    ))
      ChannelMemberResponse.fromJson(json),
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
