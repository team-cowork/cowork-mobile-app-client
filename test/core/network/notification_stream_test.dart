import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/core/network/notification_stream.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 연결마다 새 스트림을 열어 주는 가짜 SSE 서버. 테스트가 [current] 로 보낸다.
class _FakeSseServer implements HttpClientAdapter {
  _FakeSseServer({this.statusCode = 200, this.hang = false});

  final int statusCode;

  /// true 면 응답 헤더를 보내지 않고 취소될 때까지 붙잡는다.
  final bool hang;

  final connections = <StreamController<Uint8List>>[];

  StreamController<Uint8List> get current => connections.last;

  void send(String text) => current.add(Uint8List.fromList(utf8.encode(text)));

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final controller = StreamController<Uint8List>();
    connections.add(controller);
    cancelFuture?.then((_) => controller.close());
    if (hang) {
      await cancelFuture;
      throw DioException.requestCancelled(
        requestOptions: options,
        reason: '취소',
      );
    }
    return ResponseBody(
      controller.stream,
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

NotificationStream _stream(
  _FakeSseServer server, {
  Duration idleTimeout = const Duration(seconds: 75),
}) => NotificationStream.withDio(
  Dio(BaseOptions(baseUrl: 'https://example.test/api/notification'))
    ..httpClientAdapter = server,
  idleTimeout: idleTimeout,
  retryDelays: const [Duration(milliseconds: 10)],
);

/// dio 응답과 스트림 변환이 실제 이벤트 루프를 몇 번 돌아야 끝나서 잠깐 기다린다.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  test('connected 는 넘기지 않고 알림 payload 만 넘긴다', () async {
    final server = _FakeSseServer();
    final stream = _stream(server);
    addTearDown(stream.dispose);
    final received = <Map<String, dynamic>>[];
    stream.events.listen(received.add);

    stream.start();
    await _settle();
    server
      ..send('event: connected\ndata: {}\n\n')
      ..send(': ping\n\n')
      ..send('data: {"type":"CHAT_MESSAGE","title":"코워크","channelId":10}\n\n')
      ..send('data: 깨진 payload\n\n');
    await _settle();

    expect(received, [
      {'type': 'CHAT_MESSAGE', 'title': '코워크', 'channelId': 10},
    ]);
  });

  test('서버가 끊으면 다시 붙는다', () async {
    final server = _FakeSseServer();
    final stream = _stream(server);
    addTearDown(stream.dispose);

    stream.start();
    await _settle();
    await server.current.close();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(server.connections, hasLength(2));
  });

  test('아무것도 오지 않으면 끊고 다시 붙는다', () async {
    final server = _FakeSseServer();
    final stream = _stream(
      server,
      idleTimeout: const Duration(milliseconds: 20),
    );
    addTearDown(stream.dispose);

    stream.start();
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(server.connections.length, greaterThanOrEqualTo(2));
  });

  test('멈추면 다시 붙지 않는다', () async {
    final server = _FakeSseServer();
    final stream = _stream(server);
    addTearDown(stream.dispose);

    stream.start();
    await _settle();
    stream.stop();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(server.connections, hasLength(1));
  });

  test('응답 헤더가 오지 않아도 기다리다 다시 붙는다', () async {
    final server = _FakeSseServer(hang: true);
    final stream = _stream(
      server,
      idleTimeout: const Duration(milliseconds: 20),
    );
    addTearDown(stream.dispose);

    stream.start();
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(server.connections.length, greaterThanOrEqualTo(2));
  });

  test('인증이 거절되면 다시 붙지 않고, 다시 켜면 연다', () async {
    final server = _FakeSseServer(statusCode: 401);
    final stream = _stream(server);
    addTearDown(stream.dispose);

    stream.start();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(server.connections, hasLength(1));

    stream.start();
    await _settle();
    expect(server.connections, hasLength(2));
  });
}
