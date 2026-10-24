import 'dart:convert';

import 'package:cowork_app/network/sse.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<SseEvent>> _parse(List<String> chunks) => parseSse(
  Stream.fromIterable([for (final c in chunks) utf8.encode(c)]),
).toList();

void main() {
  test('이벤트 이름과 data 를 빈 줄 단위로 나눈다', () async {
    final events = await _parse([
      'event: connected\ndata: {}\n\n',
      'data: {"type":"CHAT_MESSAGE"}\n\n',
    ]);

    expect(events, [
      (event: 'connected', data: '{}'),
      (event: 'message', data: '{"type":"CHAT_MESSAGE"}'),
    ]);
  });

  test('keepalive 주석은 버리고, 조각나 온 줄도 이어 붙인다', () async {
    final events = await _parse([
      ': ping\n\n',
      'data: {"title":"코',
      '워크"}\n',
      '\n',
    ]);

    expect(events, [(event: 'message', data: '{"title":"코워크"}')]);
  });

  test('data 가 여러 줄이면 줄바꿈으로 잇는다', () async {
    final events = await _parse(['data: 첫 줄\ndata: 둘째 줄\n\n']);

    expect(events.single.data, '첫 줄\n둘째 줄');
  });

  test('끝나지 않은 이벤트는 내보내지 않는다', () async {
    final events = await _parse(['data: 아직\n']);

    expect(events, isEmpty);
  });
}
