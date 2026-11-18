import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../model/requests/edit_message_request.dart';
import '../model/requests/read_channel_request.dart';
import '../model/requests/send_message_request.dart';
import '../model/responses/message_response.dart';

/// 채널 메시지 저장소.
///
/// 메시지는 chat 서비스에 있다. 작성자는 id 만 오므로 이름은 user 서비스를 쓰는
/// `ProfileRepository.fetchDisplayNames` 로 따로 채운다.
class MessageRepository {
  MessageRepository(AuthRepository auth)
    : this.withDio(chat: createAuthedDio(ApiService.chat, auth));

  /// [files] 는 임시 주소의 파일을 받는 dio 다. 임시 주소는 서명이 들어 있어 인증
  /// 헤더가 필요 없고 게이트웨이 prefix 도 없으므로 따로 둔다.
  ///
  /// [imageCacheLimit] 는 받아 둘 이미지 용량의 상한(바이트)이다.
  MessageRepository.withDio({
    required Dio chat,
    Dio? files,
    int imageCacheLimit = defaultImageCacheLimit,
  }) : _chat = chat,
       _files = files ?? createFileDio(),
       _imageCacheLimit = imageCacheLimit;

  final Dio _chat;
  final Dio _files;

  /// 받아 둔 이미지 첨부. 메시지·첨부 순번 기준이고, 오래 안 쓴 것부터 버린다.
  final _images = <String, Uint8List>{};
  final _imageLoads = <String, Future<Uint8List>>{};
  int _imageBytes = 0;

  final int _imageCacheLimit;

  /// 받아 둘 이미지 용량의 기본 상한.
  static const defaultImageCacheLimit = 30 * 1024 * 1024;

  /// 한 번에 오는 메시지 수의 서버 상한. 이보다 적게 오면 더 이전 메시지가 없다.
  static const pageSize = 100;

  /// [fetchMessages] 의 `around` 가 기준 메시지 쪽(기준 포함 이전)과 이후 쪽에서 각각
  /// 가져오는 최대 수. 서버가 한 페이지를 반씩 나눈다.
  static const aroundHalf = pageSize ~/ 2;

  /// 채널 메시지를 최신순으로. 커서는 하나만 준다(둘 이상이면 서버가 400).
  ///
  /// - [before]: 그 메시지보다 이전 메시지.
  /// - [after]: 그 메시지보다 이후 메시지 중 가장 가까운 것들.
  /// - [around]: 그 메시지와 이전 메시지(합쳐 [aroundHalf] 개까지), 이후 메시지
  ///   [aroundHalf] 개까지. 그 메시지가 채널에 없으면 404.
  /// - 셋 다 없으면 가장 최근부터.
  ///
  /// [parentMessageId] 를 주면 그 메시지의 스레드 답글만 준다.
  Future<List<MessageResponse>> fetchMessages(
    int channelId, {
    String? before,
    String? after,
    String? around,
    String? parentMessageId,
  }) async {
    assert(
      [before, after, around].nonNulls.length <= 1,
      'before, after, around 는 하나만 줄 수 있다',
    );
    return [
      for (final json in unwrapListPayload(
        (await _chat.get<String>(
              '/chat/channels/$channelId/messages',
              queryParameters: {
                'before': ?before,
                'after': ?after,
                'around': ?around,
                'parentMessageId': ?parentMessageId,
              },
            )).data ??
            '',
      ))
        MessageResponse.fromJson(json),
    ];
  }

  /// [parentMessageId] 메시지의 스레드 답글 전부를 최신순으로. 한 번에 [pageSize] 개씩
  /// 오므로, 꽉 찬 동안 더 이전 답글을 이어서 읽는다.
  ///
  /// 서버가 `before` 를 무시해 같은 페이지만 되풀이하면 새 답글이 없는 페이지에서 멈춘다.
  Future<List<MessageResponse>> fetchReplies(
    int channelId,
    String parentMessageId,
  ) async {
    final replies = <MessageResponse>[];
    final seen = <String>{};
    String? before;
    while (true) {
      final page = await fetchMessages(
        channelId,
        before: before,
        parentMessageId: parentMessageId,
      );
      final added = [
        for (final reply in page)
          if (seen.add(reply.id)) reply,
      ];
      replies.addAll(added);
      if (page.length < pageSize || added.isEmpty) return replies;
      before = page.last.id;
    }
  }

  /// [messageId] 메시지 하나. 서버에 단건 조회가 없어, 그 메시지를 기준으로 앞뒤를
  /// 읽어 그중에서 찾는다. 응답에 없으면 [StateError].
  Future<MessageResponse> fetchMessage(int channelId, String messageId) async {
    final around = await fetchMessages(channelId, around: messageId);
    return around.firstWhere(
      (message) => message.id == messageId,
      orElse: () => throw StateError('메시지 $messageId 가 응답에 없다'),
    );
  }

  /// [messageId] 메시지의 [attachmentIndex] 번째 첨부파일을 받을 임시 주소.
  ///
  /// 서버는 누를 때마다 채널 읽기 권한을 다시 확인하고 60초만 유효한 주소를 준다. 영구
  /// 주소가 없으므로 받은 주소는 저장하지 않고 바로 쓴다.
  Future<String> fetchAttachmentDownloadUrl(
    int channelId,
    String messageId,
    int attachmentIndex,
  ) async {
    final url = unwrapPayload(
      (await _chat.get<String>(
            '/chat/channels/$channelId/messages/$messageId/attachments/$attachmentIndex/download-url',
          )).data ??
          '',
    )['downloadUrl'];
    if (url is! String || url.isEmpty) {
      throw const FormatException('다운로드 주소가 응답에 없다');
    }
    return url;
  }

  /// 이미 받아 둔 이미지 첨부. 없으면 null.
  Uint8List? cachedAttachmentImage(
    int channelId,
    String messageId,
    int attachmentIndex,
  ) {
    final key = _imageKey(channelId, messageId, attachmentIndex);
    final bytes = _images.remove(key);
    // 다시 넣어 가장 최근에 쓴 것으로 올린다.
    if (bytes != null) _images[key] = bytes;
    return bytes;
  }

  /// 이미지 첨부를 받는다. 받아 둔 게 있으면 그대로 주고, 같은 이미지를 받는 중이면
  /// 그 요청을 같이 기다린다. 없으면 임시 주소를 새로 받아 내려받는다.
  Future<Uint8List> fetchAttachmentImage(
    int channelId,
    String messageId,
    int attachmentIndex,
  ) {
    final cached = cachedAttachmentImage(channelId, messageId, attachmentIndex);
    if (cached != null) return Future.value(cached);
    final key = _imageKey(channelId, messageId, attachmentIndex);
    return _imageLoads[key] ??=
        _downloadImage(key, channelId, messageId, attachmentIndex).whenComplete(
          () {
            // 값을 돌려주면 whenComplete 가 그 Future 를 기다리므로 버린다.
            _imageLoads.remove(key);
          },
        );
  }

  Future<Uint8List> _downloadImage(
    String key,
    int channelId,
    String messageId,
    int attachmentIndex,
  ) async {
    final url = await fetchAttachmentDownloadUrl(
      channelId,
      messageId,
      attachmentIndex,
    );
    final response = await _files.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw const FormatException('받은 이미지가 비어 있다');
    }
    final bytes = Uint8List.fromList(data);
    _images[key] = bytes;
    _imageBytes += bytes.length;
    while (_imageBytes > _imageCacheLimit && _images.length > 1) {
      _imageBytes -= _images.remove(_images.keys.first)!.length;
    }
    return bytes;
  }

  static String _imageKey(int channelId, String messageId, int index) =>
      '$channelId/$messageId/$index';

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

  /// [lastReadMessageId] 까지 읽었다고 알린다.
  Future<void> markRead(int channelId, String lastReadMessageId) =>
      _chat.post<String>(
        '/chat/channels/$channelId/read',
        data: ReadChannelRequest(lastReadMessageId: lastReadMessageId).toJson(),
      );
}
