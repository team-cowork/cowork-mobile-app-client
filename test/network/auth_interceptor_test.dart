import 'dart:typed_data';

import 'package:cowork_app/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 미리 정한 상태 코드를 순서대로 돌려주면서 각 요청의 Authorization 을 기록한다.
/// 대본을 다 쓰면 마지막 코드를 계속 돌려준다.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._script);

  final List<int> _script;
  final sent = <String?>[];
  int _calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sent.add(options.headers['Authorization'] as String?);
    final status = _script[_calls.clamp(0, _script.length - 1)];
    _calls++;
    return ResponseBody.fromString(
      '{"ok":true}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 인터셉터가 붙은 dio 와, 토큰을 들고 있는 가짜 저장소를 함께 만든다.
({Dio dio, _ScriptedAdapter adapter, List<int> refreshCalls}) _subject({
  required List<int> script,
  String? token = 'old',
  required bool refreshSucceeds,
}) {
  final adapter = _ScriptedAdapter(script);
  final refreshCalls = <int>[];
  var current = token;

  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
    ..httpClientAdapter = adapter;
  dio.interceptors.add(
    AuthInterceptor(
      client: dio,
      accessToken: () => current,
      refresh: () async {
        refreshCalls.add(1);
        // 실제 restoreSession 도 실패하면 토큰을 지우고 false 를 돌려준다.
        current = refreshSucceeds ? 'new' : null;
        return refreshSucceeds;
      },
    ),
  );
  return (dio: dio, adapter: adapter, refreshCalls: refreshCalls);
}

void main() {
  test('401 이면 토큰을 갱신해 새 토큰으로 다시 보낸다', () async {
    final s = _subject(script: [401, 200], refreshSucceeds: true);

    final response = await s.dio.get<dynamic>('/notes');

    expect(response.statusCode, 200);
    expect(s.adapter.sent, ['Bearer old', 'Bearer new']);
    expect(s.refreshCalls, hasLength(1));
  });

  test('갱신에 실패하면 재시도 없이 원래 401 을 돌려준다', () async {
    final s = _subject(script: [401], refreshSucceeds: false);

    await expectLater(
      s.dio.get<dynamic>('/notes'),
      throwsA(
        isA<DioException>().having((e) => e.response?.statusCode, '상태', 401),
      ),
    );
    expect(s.adapter.sent, ['Bearer old'], reason: '재시도를 보내면 안 된다');
    expect(s.refreshCalls, hasLength(1));
  });

  test('재시도가 또 401 이어도 무한히 갱신하지 않는다', () async {
    final s = _subject(script: [401, 401], refreshSucceeds: true);

    await expectLater(
      s.dio.get<dynamic>('/notes'),
      throwsA(isA<DioException>()),
    );
    expect(s.adapter.sent, ['Bearer old', 'Bearer new'], reason: '재시도는 한 번뿐');
    expect(s.refreshCalls, hasLength(1));
  });

  test('같은 토큰으로 나간 요청들이 동시에 401 을 받아도 갱신은 한 번만 돈다', () async {
    final s = _subject(script: [401, 401, 200, 200], refreshSucceeds: true);

    final responses = await Future.wait([
      s.dio.get<dynamic>('/notes'),
      s.dio.get<dynamic>('/settings'),
    ]);

    expect(responses.map((r) => r.statusCode), everyElement(200));
    expect(s.refreshCalls, hasLength(1), reason: '갱신 폭주를 막아야 한다');
    expect(s.adapter.sent, [
      'Bearer old',
      'Bearer old',
      'Bearer new',
      'Bearer new',
    ]);
  });

  test('401 이 아닌 실패는 그대로 통과시킨다', () async {
    final s = _subject(script: [500], refreshSucceeds: true);

    await expectLater(
      s.dio.get<dynamic>('/notes'),
      throwsA(isA<DioException>()),
    );
    expect(s.adapter.sent, hasLength(1));
    expect(s.refreshCalls, isEmpty);
  });

  test('로그아웃 상태면 헤더를 붙이지도, 갱신하지도 않는다', () async {
    final s = _subject(script: [401], token: null, refreshSucceeds: true);

    await expectLater(
      s.dio.get<dynamic>('/notes'),
      throwsA(isA<DioException>()),
    );
    expect(s.adapter.sent, [null]);
    expect(s.refreshCalls, isEmpty);
  });
}
