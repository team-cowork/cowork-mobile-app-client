import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../channel/data/model/responses/channel_response.dart';
import '../../domain/search_result.dart';
import '../model/responses/search_messages_response.dart';
import '../model/responses/user_search_response.dart';
import '../model/search_result_mapping.dart';

/// 팀 안 검색 저장소.
///
/// 채널·메시지·사람이 각각 channel·chat·user 서비스에 있어 게이트웨이 prefix 가
/// 다른 dio 셋을 쓴다. 세 검색 모두 [teamId] 팀 안으로 범위가 묶인다.
class SearchRepository {
  SearchRepository(AuthRepository auth)
    : this.withDio(
        channel: createAuthedDio(ApiService.channel, auth),
        chat: createAuthedDio(ApiService.chat, auth),
        user: createAuthedDio(ApiService.user, auth),
      );

  SearchRepository.withDio({
    required Dio channel,
    required Dio chat,
    required Dio user,
  }) : _channel = channel,
       _chat = chat,
       _user = user;

  final Dio _channel;
  final Dio _chat;
  final Dio _user;

  /// 사람 검색 한 번에 받는 수. 서버 기본값과 같다.
  static const peoplePageSize = 20;

  /// 메시지 검색 한 페이지 크기. 서버 기본값은 50 이다.
  static const messagePageSize = 20;

  /// [teamId] 팀에서 내가 볼 수 있는 채널 중 이름이 [query] 와 맞는 것.
  Future<List<SearchChannelResult>> searchChannels({
    required int teamId,
    required String query,
  }) async => [
    for (final json in unwrapListPayload(
      (await _channel.get<String>(
            '/search/channels',
            queryParameters: {'teamId': teamId, 'q': query},
          )).data ??
          '',
    ))
      searchChannelResultOf(ChannelResponse.fromJson(json)),
  ];

  /// [teamId] 팀 멤버 중 이름·닉네임이 [query] 와 맞는 사람. 첫 페이지만 받는다.
  Future<List<SearchPersonResult>> searchPeople({
    required int teamId,
    required String query,
  }) async {
    final response = UserSearchResponse.fromJson(
      unwrapPayload(
        (await _user.get<String>(
              '/users/search',
              queryParameters: {
                'teamId': teamId,
                'q': query,
                'page_size': peoplePageSize,
              },
            )).data ??
            '',
      ),
    );
    return [for (final user in response.items) searchPersonResultOf(user)];
  }

  /// [teamId] 팀에서 내가 속한 채널의 메시지를 최신순으로.
  ///
  /// [before] 에 이전 페이지의 [SearchMessagePage.nextCursor] 를 넣으면 그 다음
  /// 페이지를 준다.
  Future<SearchMessagePage> searchMessages({
    required int teamId,
    required String query,
    String? before,
  }) async => searchMessagePageOf(
    SearchMessagesResponse.fromJson(
      unwrapPayload(
        (await _chat.get<String>(
              '/chat/search/messages',
              queryParameters: {
                'teamId': teamId,
                'q': query,
                'limit': messagePageSize,
                'before': ?before,
              },
            )).data ??
            '',
      ),
    ),
  );
}
