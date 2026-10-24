import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cowork_app/feature/auth/data/auth_repository.dart';
import 'package:cowork_app/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// 실제 dio 를 거쳐 나온 DioException 으로 검증한다. 손으로 만든 DioException 은
/// validateStatus / responseType 이 바뀌어도 통과해버려서 회귀를 못 잡는다.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, this.body);

  final int statusCode;
  final String body;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 연결 자체가 안 되는 상황. dio 가 응답 없는 DioException 으로 바꿔 던진다.
class _OfflineAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => throw const SocketException('no route to host');

  @override
  void close({bool force = false}) {}
}

/// `createDio()` 와 같은 BaseOptions 의 dio. baseUrl 은 dart-define 없이 비어 있어
/// 여기서만 더미 값을 쓴다.
Dio _dio(HttpClientAdapter adapter) => Dio(
  BaseOptions(
    baseUrl: 'https://example.test/api',
    contentType: Headers.jsonContentType,
    responseType: ResponseType.plain,
  ),
)..httpClientAdapter = adapter;

/// refresh token 이 저장된 상태의 저장소.
AuthRepository _signedIn(HttpClientAdapter adapter) {
  FlutterSecureStorage.setMockInitialValues({'cowork.refresh_token': 'r'});
  return AuthRepository(
    dio: _dio(adapter),
    storage: const FlutterSecureStorage(),
  );
}

Future<String?> _storedRefreshToken() =>
    const FlutterSecureStorage().read(key: 'cowork.refresh_token');

/// `createDio()` 와 같은 BaseOptions 로 POST 한 뒤 예외를 돌려준다.
Future<DioException> _postFailure(int status, String body) async {
  final dio = _dio(_StubAdapter(status, body));
  try {
    await dio.post<String>('/auth/refresh', data: {'refresh_token': 'r'});
    fail('$status 는 throw 했어야 한다');
  } on DioException catch (e) {
    return e;
  }
}

void main() {
  test('S256 code_challenge는 RFC 7636 Appendix B 벡터와 일치한다', () {
    expect(
      codeChallengeOf('dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk'),
      'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM',
    );
  });

  test('code_verifier는 RFC 7636 길이/문자 규격을 지킨다', () {
    final verifier = createCodeVerifier();
    expect(verifier.length, inInclusiveRange(43, 128));
    expect(verifier, matches(r'^[A-Za-z0-9\-._~]+$'));
    expect(verifier, isNot(createCodeVerifier()));
  });

  test('게이트웨이 envelope과 raw 응답을 모두 벗겨낸다', () {
    expect(
      unwrapPayload('{"status":"OK","code":200,"message":"","data":{"a":1}}'),
      {'a': 1},
    );
    expect(unwrapPayload('{"access_token":"t"}'), {'access_token': 't'});
    expect(unwrapPayload(''), isEmpty);
  });

  test('서버가 거절하면 상태 코드와 서버 사유를 살린다', () async {
    final e = await _postFailure(401, jsonEncode({'message': 'Unauthorized'}));
    expect(
      e.response,
      isNotNull,
      reason: 'dio 가 4xx 를 response 없이 던지면 매핑이 무너진다',
    );
    expect(authExceptionOf(e).message, '(401) Unauthorized');
  });

  test('JSON 이 아닌 오류 본문은 상태 코드 기본 문구로 떨어진다', () async {
    final e = await _postFailure(502, '<html>502 Bad Gateway</html>');
    expect(authExceptionOf(e).message, '(502) 서버에 연결할 수 없습니다.');
  });

  test('연결 자체가 실패하면 네트워크 문구를 쓴다', () {
    final e = DioException.connectionError(
      requestOptions: RequestOptions(path: '/auth/refresh'),
      reason: 'no route to host',
    );
    expect(e.response, isNull);
    expect(authExceptionOf(e).message, '네트워크에 연결할 수 없습니다.');
  });

  group('restoreSession', () {
    test('서버가 refresh token 을 거절하면 토큰을 지우고 세션 만료를 알린다', () async {
      final repository = _signedIn(_StubAdapter(401, '{"message":"expired"}'));
      final expired = <void>[];
      repository.sessionExpired.listen(expired.add);

      expect(await repository.restoreSession(), isFalse);
      await pumpEventQueue();

      expect(await _storedRefreshToken(), isNull);
      expect(expired, hasLength(1));
    });

    test('연결이 안 돼 실패하면 토큰을 남기고 만료를 알리지 않는다', () async {
      final repository = _signedIn(_OfflineAdapter());
      final expired = <void>[];
      repository.sessionExpired.listen(expired.add);

      expect(await repository.restoreSession(), isFalse);
      await pumpEventQueue();

      expect(await _storedRefreshToken(), 'r');
      expect(expired, isEmpty);
    });

    test('서버 장애(5xx)로 실패해도 토큰을 남긴다', () async {
      final repository = _signedIn(_StubAdapter(503, ''));

      expect(await repository.restoreSession(), isFalse);
      expect(await _storedRefreshToken(), 'r');
    });

    test('동시에 불러도 갱신 요청은 한 번만 보낸다', () async {
      final adapter = _StubAdapter(
        200,
        jsonEncode({'access_token': 'a', 'refresh_token': 'r2'}),
      );
      final repository = _signedIn(adapter);

      final results = await Future.wait([
        repository.restoreSession(),
        repository.restoreSession(),
      ]);

      expect(results, [true, true]);
      expect(adapter.calls, 1);
      expect(repository.accessToken, 'a');
      expect(await _storedRefreshToken(), 'r2');
    });
  });
}
