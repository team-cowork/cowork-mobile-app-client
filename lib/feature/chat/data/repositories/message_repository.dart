import 'package:dio/dio.dart';

import '../../../../network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../model/requests/edit_message_request.dart';
import '../model/requests/send_message_request.dart';
import '../model/responses/message_response.dart';
import '../model/responses/user_display_name_response.dart';

/// 채널 메시지 저장소.
///
/// 메시지는 chat 서비스에 있고 작성자는 id 만 오므로, 이름은 user 서비스에서 한꺼번에
/// 읽는다. 그래서 게이트웨이 prefix 가 다른 dio 둘을 쓴다.
class MessageRepository {
  MessageRepository(AuthRepository auth)
    : this.withDio(
        chat: createAuthedDio(ApiService.chat, auth),
        user: createAuthedDio(ApiService.user, auth),
      );

  MessageRepository.withDio({required Dio chat, required Dio user})
    : _chat = chat,
      _user = user;

  final Dio _chat;
  final Dio _user;

  /// 한 번에 오는 메시지 수의 서버 상한. 이보다 적게 오면 더 이전 메시지가 없다.
  static const pageSize = 100;

  /// `/users/batch` 가 한 번에 받는 id 수의 서버 상한.
  static const _userBatchSize = 100;

  /// [before] 메시지보다 이전 메시지를 최신순으로. [before] 가 없으면 가장 최근부터.
  Future<List<MessageResponse>> fetchMessages(
    int channelId, {
    String? before,
  }) async => [
    for (final json in unwrapListPayload(
      (await _chat.get<String>(
            '/chat/channels/$channelId/messages',
            queryParameters: {'before': ?before},
          )).data ??
          '',
    ))
      MessageResponse.fromJson(json),
  ];

  /// 메시지를 보낸다. 서버는 큐에 넣고 바로 돌아오고, 저장된 메시지는 소켓으로 온다.
  Future<void> sendMessage(int channelId, SendMessageRequest request) =>
      _chat.post<String>(
        '/chat/channels/$channelId/messages',
        data: request.toJson(),
      );

  /// 메시지 내용을 고친다. 바뀐 내용은 소켓 `message:edited` 로도 온다.
  Future<void> editMessage(
    int channelId,
    String messageId,
    EditMessageRequest request,
  ) => _chat.patch<String>(
    '/chat/channels/$channelId/messages/$messageId',
    data: request.toJson(),
  );

  /// 메시지를 지운다. 지운 사실은 소켓 `message:deleted` 로도 온다.
  Future<void> deleteMessage(int channelId, String messageId) =>
      _chat.delete<String>('/chat/channels/$channelId/messages/$messageId');

  /// [userIds] 사용자의 표시 이름. 서버 상한에 맞춰 나눠 읽는다.
  Future<List<UserDisplayNameResponse>> fetchDisplayNames(
    Iterable<int> userIds,
  ) async {
    final ids = userIds.toSet().toList();
    return [
      for (var start = 0; start < ids.length; start += _userBatchSize)
        ...await _fetchDisplayNameBatch(ids.skip(start).take(_userBatchSize)),
    ];
  }

  Future<List<UserDisplayNameResponse>> _fetchDisplayNameBatch(
    Iterable<int> ids,
  ) async {
    final users = unwrapPayload(
      (await _user.get<String>(
            '/users/batch',
            queryParameters: {'ids': ids.join(',')},
          )).data ??
          '',
    )['users'];
    if (users is! List) return const [];
    return [
      for (final json in users.whereType<Map<String, dynamic>>())
        UserDisplayNameResponse.fromJson(json),
    ];
  }
}
