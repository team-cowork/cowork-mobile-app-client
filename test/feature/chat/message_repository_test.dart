import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/chat/data/model/requests/send_message_request.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

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
