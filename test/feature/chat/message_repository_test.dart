import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/chat/data/model/requests/edit_message_request.dart';
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
    if (uri.path.endsWith('/users/batch')) {
      final ids = uri.queryParameters['ids']!.split(',');
      return _json({
        'data': {
          'users': [
            for (final id in ids) {'id': int.parse(id), 'name': '사용자$id'},
          ],
        },
      });
    }
    return ResponseBody.fromString('', 204);
  }

  static ResponseBody _json(Object body) => ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

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
  return MessageRepository.withDio(chat: dio('chat'), user: dio('user'));
}

void main() {
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
        MessageRepository.withDio(
          chat: messageDio(gateway, 'chat'),
          user: messageDio(gateway, 'user'),
        );

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

  test('작성자 이름은 중복을 빼고 100명씩 나눠 읽는다', () async {
    final server = _RecordingServer();

    final users = await _repository(
      server,
    ).fetchDisplayNames([for (var id = 1; id <= 150; id++) id, 1, 2]);

    expect(users, hasLength(150));
    expect(server.calls, hasLength(2));
    expect(server.calls.last, startsWith('GET /user/users/batch?ids=101%2C'));
  });
}
