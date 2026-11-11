import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cowork_app/core/network/dio_client.dart';
import 'package:cowork_app/core/network/http_error_message.dart';
import 'package:cowork_app/feature/auth/data/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// 실제 dio 를 거쳐 나온 DioException 으로 검증한다. 손으로 만든 DioException 은
/// validateStatus / responseType 이 바뀌어도 통과해버려서 회귀를 못 잡는다.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, this.body, {this.hold});

  final int statusCode;
  final String body;

  /// 주면 이게 끝날 때까지 응답을 붙잡아 둔다. 응답이 늦게 오는 상황을 만든다.
  final Future<void>? hold;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    await hold;
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

/// 경로마다 다른 응답을 준다. 로그인(갱신) 뒤 로그아웃처럼 요청이 여럿인 흐름용.
class _RouteAdapter implements HttpClientAdapter {
  _RouteAdapter(this.routes);

  /// 경로 끝부분 → (상태 코드, 본문)
  final Map<String, (int, String)> routes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final (status, body) = routes.entries
        .firstWhere((route) => options.path.endsWith(route.key))
        .value;
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 로그인 흐름용. 경로마다 (상태 코드, 본문, Set-Cookie) 를 주고 보낸 요청을 남긴다.
class _LoginAdapter implements HttpClientAdapter {
  _LoginAdapter(this.routes);

  /// 경로 끝부분 → (상태 코드, 본문, Set-Cookie 값들)
  final Map<String, (int, String, List<String>)> routes;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body, cookies) = routes.entries
        .firstWhere((route) => options.path.endsWith(route.key))
        .value;
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        'set-cookie': cookies,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 읽기에 실패하는 secure storage. keystore 가 손상된 기기를 흉내 낸다.
class _BrokenStorage extends Fake implements FlutterSecureStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Future<String?>.error(PlatformException(code: 'keystore'));
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
  group('signIn', () {
    const authorizationUrl = 'https://datagsm.test/authorize?state=s1';
    const loginCookie =
        '__Host-cowork_oauth_h1=attempt-1; Path=/; Max-Age=600; HttpOnly; Secure; SameSite=None';

    /// 게이트웨이 envelope 으로 감싼 `/auth/authorize` 응답.
    final authorizeOk = (
      200,
      jsonEncode({
        'data': {'authorization_url': authorizationUrl},
      }),
      [loginCookie],
    );
    final tokensOk = (
      200,
      jsonEncode({'access_token': 'a', 'refresh_token': 'r'}),
      const <String>[],
    );

    /// 브라우저 대신 [callback] 을 돌려주고 열려던 URL 을 [opened] 에 남긴다.
    (AuthRepository, List<String>) repositoryOf(
      _LoginAdapter adapter, {
      String callback = 'cowork://oauth/callback?state=s1&code=c1',
    }) {
      FlutterSecureStorage.setMockInitialValues({});
      final opened = <String>[];
      final repository = AuthRepository(
        dio: _dio(adapter),
        storage: const FlutterSecureStorage(),
        authenticate: ({required url, required callbackUrlScheme}) async {
          opened.add(url);
          return callback;
        },
      );
      return (repository, opened);
    }

    test('서버가 준 인가 URL 을 열고 콜백을 로그인 시도 쿠키와 함께 넘긴다', () async {
      final adapter = _LoginAdapter({
        '/auth/authorize': authorizeOk,
        '/auth/callback': tokensOk,
      });
      final (repository, opened) = repositoryOf(adapter);

      await repository.signIn();

      expect(opened, [authorizationUrl]);
      final [start, callback] = adapter.requests;
      expect(start.path, '/auth/authorize');
      expect(start.data, {'redirect_uri': 'cowork://oauth/callback'});
      expect(callback.path, '/auth/callback');
      expect(callback.data, {'state': 's1', 'code': 'c1'});
      expect(callback.headers['Cookie'], '__Host-cowork_oauth_h1=attempt-1');
      expect(callback.data, isNot(contains('code_verifier')));
      expect(repository.accessToken, 'a');
      expect(await _storedRefreshToken(), 'r');
    });

    for (final (name, authorize) in [
      (
        '로그인 시도 쿠키가 없으면',
        (
          200,
          jsonEncode({'authorization_url': authorizationUrl}),
          const <String>[],
        ),
      ),
      ('인가 URL 이 없으면', (200, '{}', [loginCookie])),
    ]) {
      test('$name 브라우저를 열지 않고 실패한다', () async {
        final adapter = _LoginAdapter({'/auth/authorize': authorize});
        final (repository, opened) = repositoryOf(adapter);

        await expectLater(
          repository.signIn(),
          throwsA(
            isA<AuthFailure>().having(
              (f) => f.kind,
              'kind',
              AuthFailureKind.invalidLoginStart,
            ),
          ),
        );
        expect(opened, isEmpty);
      });
    }

    test('DataGSM 이 거절하면 서버에 알리고 DataGSM 사유로 실패한다', () async {
      final adapter = _LoginAdapter({
        '/auth/authorize': authorizeOk,
        // 서버는 거절 콜백도 인증 실패로 응답한다.
        '/auth/callback': (401, '{"error":"authentication failed"}', const []),
      });
      final (repository, _) = repositoryOf(
        adapter,
        callback: 'cowork://oauth/callback?state=s1&error=access_denied',
      );

      await expectLater(
        repository.signIn(),
        throwsA(
          isA<AuthFailure>()
              .having((f) => f.kind, 'kind', AuthFailureKind.codeMissing)
              .having((f) => f.detail, 'detail', 'access_denied'),
        ),
      );
      final callback = adapter.requests.last;
      expect(callback.data, {'state': 's1', 'error': 'access_denied'});
      expect(callback.headers['Cookie'], '__Host-cowork_oauth_h1=attempt-1');
      expect(await _storedRefreshToken(), isNull);
    });

    for (final (name, callback) in [
      ('state 가 없으면', 'cowork://oauth/callback?code=c1'),
      ('state 가 비어 있으면', 'cowork://oauth/callback?state=&code=c1'),
      (
        'DataGSM 이 거절했는데 state 가 없으면',
        'cowork://oauth/callback?error=access_denied',
      ),
    ]) {
      test('$name 서버에 콜백을 보내지 않고 실패한다', () async {
        final adapter = _LoginAdapter({
          '/auth/authorize': authorizeOk,
          '/auth/callback': tokensOk,
        });
        final (repository, _) = repositoryOf(adapter, callback: callback);

        await expectLater(
          repository.signIn(),
          throwsA(
            isA<AuthFailure>().having(
              (f) => f.kind,
              'kind',
              AuthFailureKind.stateMissing,
            ),
          ),
        );
        expect(adapter.requests.map((r) => r.path), ['/auth/authorize']);
        expect(await _storedRefreshToken(), isNull);
      });
    }

    test('서버가 콜백을 거절하면 DioException 을 그대로 던지고 토큰을 남기지 않는다', () async {
      final adapter = _LoginAdapter({
        '/auth/authorize': authorizeOk,
        '/auth/callback': (401, '{"error":"authentication failed"}', const []),
      });
      final (repository, _) = repositoryOf(adapter);

      await expectLater(
        repository.signIn(),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(repository.accessToken, isNull);
      expect(await _storedRefreshToken(), isNull);
    });
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
    expect(dioErrorMessage(e), '(401) Unauthorized');
  });

  test('JSON 이 아닌 오류 본문은 상태 코드 기본 문구로 떨어진다', () async {
    final e = await _postFailure(502, '<html>502 Bad Gateway</html>');
    expect(dioErrorMessage(e), '(502) 서버에 연결할 수 없습니다.');
  });

  test('연결 자체가 실패하면 네트워크 문구를 쓴다', () {
    final e = DioException.connectionError(
      requestOptions: RequestOptions(path: '/auth/refresh'),
      reason: 'no route to host',
    );
    expect(e.response, isNull);
    expect(dioErrorMessage(e), '네트워크에 연결할 수 없습니다.');
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

    test('갱신 중에 로그아웃하면 늦게 온 성공 응답이 토큰을 되살리지 않는다', () async {
      final response = Completer<void>();
      final repository = _signedIn(
        _StubAdapter(
          200,
          jsonEncode({'access_token': 'a', 'refresh_token': 'r2'}),
          hold: response.future,
        ),
      );

      final restoring = repository.restoreSession();
      await pumpEventQueue();
      await repository.signOut();
      response.complete();

      expect(await restoring, isFalse);
      expect(repository.accessToken, isNull);
      expect(await _storedRefreshToken(), isNull);
    });

    test('갱신 중에 로그아웃하고 다시 로그인하면 늦게 온 401 이 새 토큰을 지우지 않는다', () async {
      final response = Completer<void>();
      final repository = _signedIn(
        _StubAdapter(401, '{"message":"expired"}', hold: response.future),
      );
      final expired = <void>[];
      repository.sessionExpired.listen(expired.add);

      final restoring = repository.restoreSession();
      await pumpEventQueue();
      await repository.signOut();
      // 로그인 결과만 흉내 낸다.
      await const FlutterSecureStorage().write(
        key: 'cowork.refresh_token',
        value: 'new',
      );
      response.complete();

      expect(await restoring, isFalse);
      await pumpEventQueue();
      expect(await _storedRefreshToken(), 'new');
      expect(expired, isEmpty);
    });

    test('서버가 400 으로 거절해도 토큰을 지우고 세션 만료를 알린다', () async {
      final repository = _signedIn(
        _StubAdapter(400, '{"error":"invalid_grant"}'),
      );
      final expired = <void>[];
      repository.sessionExpired.listen(expired.add);

      expect(await repository.restoreSession(), isFalse);
      await pumpEventQueue();

      expect(await _storedRefreshToken(), isNull);
      expect(expired, hasLength(1));
    });

    for (final (name, body) in [
      ('토큰이 빠진 응답', '{"access_token":"a"}'),
      ('JSON 이 아닌 응답', '<html>ok</html>'),
    ]) {
      test('200 이어도 $name 이면 예외 없이 false 를 주고 토큰을 남긴다', () async {
        final repository = _signedIn(_StubAdapter(200, body));
        final expired = <void>[];
        repository.sessionExpired.listen(expired.add);

        expect(await repository.restoreSession(), isFalse);
        await pumpEventQueue();

        expect(await _storedRefreshToken(), 'r');
        expect(expired, isEmpty);
      });
    }

    test('저장소 읽기에 실패해도 예외 없이 false 를 준다', () async {
      final repository = AuthRepository(
        dio: _dio(_StubAdapter(200, '')),
        storage: _BrokenStorage(),
      );

      expect(await repository.restoreSession(), isFalse);
    });
  });

  group('signOut', () {
    /// 갱신으로 access token 까지 받은, 로그아웃 요청을 보낼 수 있는 상태.
    Future<AuthRepository> loggedIn((int, String) signout) async {
      final repository = _signedIn(
        _RouteAdapter({
          '/auth/refresh': (
            200,
            jsonEncode({'access_token': 'a', 'refresh_token': 'r2'}),
          ),
          '/auth/signout': signout,
        }),
      );
      expect(await repository.restoreSession(), isTrue);
      return repository;
    }

    for (final (name, signout) in [
      ('서버가 거절해도(500)', (500, '')),
      ('응답 본문이 JSON 이 아니어도', (200, '<html>portal</html>')),
    ]) {
      test('$name 로컬 토큰을 지운다', () async {
        final repository = await loggedIn(signout);

        await repository.signOut();

        expect(repository.accessToken, isNull);
        expect(await _storedRefreshToken(), isNull);
      });
    }
  });
}
