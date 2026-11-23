import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/chat/data/model/requests/edit_message_request.dart';
import 'package:cowork_app/feature/chat/data/model/requests/message_attachment_request.dart';
import 'package:cowork_app/feature/chat/data/model/requests/send_message_request.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'channel_message_test_server.dart';

/// 받은 요청을 `METHOD 경로?쿼리` 와 본문으로 적어 두고 빈 성공 응답을 주는 서버.
class _RecordingServer implements HttpClientAdapter {
  final calls = <String>[];
  final bodies = <String, Object?>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final uri = options.uri;
    final call =
        '${options.method} ${uri.path.replaceFirst('/api', '')}'
        '${uri.hasQuery ? '?${uri.query}' : ''}';
    calls.add(call);
    if (requestStream != null) {
      final bytes = (await requestStream.toList()).expand((c) => c).toList();
      if (bytes.isNotEmpty) bodies[call] = jsonDecode(utf8.decode(bytes));
    }
    return ResponseBody.fromString('', 204);
  }

  @override
  void close({bool force = false}) {}
}

MessageRepository _repository(_RecordingServer server) {
  Dio dio(String service) => Dio(
    BaseOptions(
      baseUrl: 'https://example.test/api/$service',
      contentType: Headers.jsonContentType,
      responseType: ResponseType.plain,
    ),
  )..httpClientAdapter = server;
  return MessageRepository.withDio(chat: dio('chat'));
}

void main() {
  group('이미지 첨부', () {
    MessageRepository repositoryOf(
      FakeMessageGateway gateway,
      FakeFilesServer files, {
      int imageCacheLimit = MessageRepository.defaultImageCacheLimit,
    }) => MessageRepository.withDio(
      chat: messageDio(gateway, 'chat'),
      files: filesDio(files),
      imageCacheLimit: imageCacheLimit,
    );

    test('임시 주소를 받아 이미지를 내려받는다', () async {
      final gateway = FakeMessageGateway();
      final files = FakeFilesServer();

      final bytes = await repositoryOf(
        gateway,
        files,
      ).fetchAttachmentImage(10, 'img1', 0);

      expect(bytes, tinyPng);
      expect(files.requests, ['https://files.test/img1.png']);
    });

    test('한 번 받은 이미지는 주소를 다시 받지 않고 쓴다', () async {
      final gateway = FakeMessageGateway();
      final files = FakeFilesServer();
      final repository = repositoryOf(gateway, files);

      await repository.fetchAttachmentImage(10, 'img1', 0);
      gateway.calls.clear();
      final again = await repository.fetchAttachmentImage(10, 'img1', 0);

      expect(again, tinyPng);
      expect(repository.cachedAttachmentImage(10, 'img1', 0), tinyPng);
      expect(gateway.calls, isEmpty);
      expect(files.requests, hasLength(1));
    });

    test('같은 이미지를 받는 중이면 그 요청을 같이 기다린다', () async {
      final gateway = FakeMessageGateway();
      final gate = Completer<void>();
      final files = FakeFilesServer()..gate = gate.future;
      final repository = repositoryOf(gateway, files);

      // 첫 요청이 아직 끝나지 않은 사이에 같은 이미지를 또 부른다.
      final first = repository.fetchAttachmentImage(10, 'img1', 0);
      await pumpEventQueue();
      final second = repository.fetchAttachmentImage(10, 'img1', 0);
      gate.complete();
      await Future.wait([first, second]);

      expect(files.requests, hasLength(1));
    });

    test('상한을 넘으면 가장 오래 안 쓴 이미지부터 버린다', () async {
      final gateway = FakeMessageGateway();
      final files = FakeFilesServer();
      // 두 장까지만 들어가는 상한.
      final repository = repositoryOf(
        gateway,
        files,
        imageCacheLimit: tinyPng.length * 2,
      );

      await repository.fetchAttachmentImage(10, 'img1', 0);
      await repository.fetchAttachmentImage(10, 'img2', 0);
      // img1 을 다시 쓰면 가장 최근에 쓴 것이 된다. 이제 img2 가 가장 오래됐다.
      expect(repository.cachedAttachmentImage(10, 'img1', 0), isNotNull);
      await repository.fetchAttachmentImage(10, 'img3', 0);

      expect(repository.cachedAttachmentImage(10, 'img1', 0), isNotNull);
      expect(repository.cachedAttachmentImage(10, 'img3', 0), isNotNull);
      expect(repository.cachedAttachmentImage(10, 'img2', 0), isNull);
    });

    test('한 장이 상한보다 커도 방금 받은 한 장은 남긴다', () async {
      final gateway = FakeMessageGateway();
      final repository = repositoryOf(
        gateway,
        FakeFilesServer(),
        imageCacheLimit: 1,
      );

      await repository.fetchAttachmentImage(10, 'img1', 0);

      expect(repository.cachedAttachmentImage(10, 'img1', 0), tinyPng);
    });

    test('받지 못하면 저장하지 않고, 다시 부르면 새 주소로 받는다', () async {
      final gateway = FakeMessageGateway();
      final files = FakeFilesServer()..failing = true;
      final repository = repositoryOf(gateway, files);

      await expectLater(
        repository.fetchAttachmentImage(10, 'img1', 0),
        throwsA(isA<DioException>()),
      );
      expect(repository.cachedAttachmentImage(10, 'img1', 0), isNull);

      files.failing = false;
      final bytes = await repository.fetchAttachmentImage(10, 'img1', 0);

      expect(bytes, tinyPng);
      expect(
        gateway.calls.where((c) => c.endsWith('/download-url')),
        hasLength(2),
      );
    });
  });

  test('첨부파일 다운로드 주소는 메시지와 첨부 순번으로 요청해 읽는다', () async {
    final gateway = FakeMessageGateway();
    final repository = MessageRepository.withDio(
      chat: messageDio(gateway, 'chat'),
    );

    final url = await repository.fetchAttachmentDownloadUrl(10, 'm1', 0);

    expect(url, 'https://files.test/a.pdf');
    expect(gateway.calls, [
      'GET /chat/chat/channels/10/messages/m1/attachments/0/download-url',
    ]);
  });

  test('다운로드 주소가 응답에 없으면 실패한다', () async {
    final gateway = FakeMessageGateway();
    final repository = MessageRepository.withDio(
      chat: messageDio(gateway, 'chat'),
    );

    expect(
      repository.fetchAttachmentDownloadUrl(10, 'm1', 1),
      throwsA(isA<FormatException>()),
    );
  });

  test('전송은 내용과 clientMessageId 를 보낸다', () async {
    final server = _RecordingServer();

    await _repository(server).sendMessage(
      10,
      const SendMessageRequest(content: '안녕', clientMessageId: 'c-1'),
    );

    expect(server.bodies['POST /chat/chat/channels/10/messages'], {
      'content': '안녕',
      'clientMessageId': 'c-1',
    });
  });

  test('답글 전송은 부모 메시지 id 를 함께 보낸다', () async {
    final server = _RecordingServer();

    await _repository(server).sendMessage(
      10,
      const SendMessageRequest(
        content: '답글',
        clientMessageId: 'c-1',
        parentMessageId: 'm1',
      ),
    );

    expect(server.bodies['POST /chat/chat/channels/10/messages'], {
      'content': '답글',
      'clientMessageId': 'c-1',
      'parentMessageId': 'm1',
    });
  });

  test('파일 전송은 FILE 형식과 확정 키를 보낸다', () async {
    final server = _RecordingServer();

    await _repository(server).sendMessage(
      10,
      const SendMessageRequest(
        content: '',
        clientMessageId: 'c-1',
        type: 'FILE',
        attachments: [
          MessageAttachmentRequest(objectKey: 'chat-files/a'),
          MessageAttachmentRequest(objectKey: 'chat-files/b'),
        ],
      ),
    );

    expect(server.bodies['POST /chat/chat/channels/10/messages'], {
      'content': '',
      'clientMessageId': 'c-1',
      'type': 'FILE',
      'attachments': [
        {'objectKey': 'chat-files/a'},
        {'objectKey': 'chat-files/b'},
      ],
    });
  });

  test('수정은 PATCH 로 바꿀 내용을 보낸다', () async {
    final server = _RecordingServer();

    await _repository(
      server,
    ).editMessage(10, 'm1', const EditMessageRequest(content: '고친 내용'));

    expect(server.bodies['PATCH /chat/chat/channels/10/messages/m1'], {
      'content': '고친 내용',
    });
  });

  test('삭제는 메시지 경로로 DELETE 를 보낸다', () async {
    final server = _RecordingServer();

    await _repository(server).deleteMessage(10, 'm1');

    expect(server.calls, ['DELETE /chat/chat/channels/10/messages/m1']);
  });

  test('읽음은 마지막으로 읽은 메시지 id 를 보낸다', () async {
    final server = _RecordingServer();

    await _repository(server).markRead(10, 'm2');

    expect(server.bodies['POST /chat/chat/channels/10/read'], {
      'lastReadMessageId': 'm2',
    });
  });

  test('목록은 before 가 있을 때만 커서를 붙인다', () async {
    final server = _RecordingServer();
    final repository = _repository(server);

    await repository.fetchMessages(10);
    await repository.fetchMessages(10, before: 'm5');

    expect(server.calls, [
      'GET /chat/chat/channels/10/messages',
      'GET /chat/chat/channels/10/messages?before=m5',
    ]);
  });

  test('답글 목록은 parentMessageId 를 쿼리로 붙인다', () async {
    final server = _RecordingServer();

    await _repository(
      server,
    ).fetchMessages(10, before: 'm5', parentMessageId: 'm1');

    expect(server.calls, [
      'GET /chat/chat/channels/10/messages?before=m5&parentMessageId=m1',
    ]);
  });

  group('스레드', () {
    MessageRepository repository(FakeMessageGateway gateway) =>
        MessageRepository.withDio(chat: messageDio(gateway, 'chat'));

    test('답글은 한 페이지가 꽉 차는 동안 더 이전 답글을 이어서 읽는다', () async {
      final gateway = FakeMessageGateway(
        replies: [
          for (var i = 150; i > 0; i--)
            messageJson('r$i', 2, '답글 $i', parentMessageId: 'm1'),
        ],
      );

      final replies = await repository(gateway).fetchReplies(10, 'm1');

      expect(replies, hasLength(150));
      expect(replies.first.id, 'r150');
      expect(replies.last.id, 'r1');
      expect(gateway.calls, [
        'GET /chat/chat/channels/10/messages?parentMessageId=m1',
        'GET /chat/chat/channels/10/messages?before=r51&parentMessageId=m1',
      ]);
    });

    test('서버가 before 를 무시해 같은 페이지만 되풀이해도 멈춘다', () async {
      final gateway = FakeMessageGateway(
        replies: [
          for (var i = 150; i > 0; i--)
            messageJson('r$i', 2, '답글 $i', parentMessageId: 'm1'),
        ],
      )..ignoredCursors = {'before'};

      final replies = await repository(gateway).fetchReplies(10, 'm1');

      expect(replies, hasLength(MessageRepository.pageSize));
      expect(gateway.calls, hasLength(2));
    });

    test('답글이 없으면 한 번만 읽고 빈 목록을 돌려준다', () async {
      final gateway = FakeMessageGateway();

      final replies = await repository(gateway).fetchReplies(10, 'm1');

      expect(replies, isEmpty);
      expect(gateway.calls, hasLength(1));
    });

    test('메시지 하나는 그 메시지 기준 앞뒤를 읽어 id 로 찾는다', () async {
      final gateway = FakeMessageGateway();

      final message = await repository(gateway).fetchMessage(10, 'm1');

      expect(message.id, 'm1');
      expect(message.content, '첫 번째');
      expect(gateway.calls, ['GET /chat/chat/channels/10/messages?around=m1']);
    });

    test('기준 메시지가 채널에 없으면 서버가 404 로 거절한다', () async {
      final gateway = FakeMessageGateway();

      await expectLater(
        repository(gateway).fetchMessage(10, 'nope'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            404,
          ),
        ),
      );
    });

    test('서버가 around 를 무시해 기준 메시지가 응답에 없으면 StateError 다', () async {
      final gateway = FakeMessageGateway()..ignoredCursors = {'around'};

      await expectLater(
        repository(gateway).fetchMessage(10, 'nope'),
        throwsStateError,
      );
    });
  });
}
