import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';
import 'dgsm_oauth_config.dart';

/// 서버 요청([DioException]) 밖에서 로그인이 실패한 종류.
enum AuthFailureKind {
  /// 사용자가 브라우저 로그인을 닫았다.
  canceled,

  /// 브라우저 인증 자체가 실패했다.
  browserFailed,

  /// 로그인 시작 응답에 인가 URL 이나 로그인 시도 쿠키가 없다.
  invalidLoginStart,

  /// 콜백에 state 가 없거나 비어 있어 서버가 이 로그인 시도와 맞춰 볼 수 없다.
  stateMissing,

  /// 인가 코드 없이 돌아왔다.
  codeMissing,

  /// 토큰 응답에 access/refresh token 이 없다.
  invalidTokenResponse,
}

/// 무슨 일이 있었는지만 알리는 로그인 실패. 사용자 문구는 Bloc 이 정한다.
class AuthFailure implements Exception {
  const AuthFailure(this.kind, {this.detail, this.cause});

  final AuthFailureKind kind;

  /// DataGSM 이 인가 코드 대신 돌려준 사유(`error_description`/`error`).
  final String? detail;

  /// 이 실패로 바꾸기 전의 원래 예외. 로그로 원인을 찾을 때 쓴다.
  final Object? cause;

  @override
  String toString() {
    final reason = detail ?? cause;
    return reason == null
        ? 'AuthFailure(${kind.name})'
        : 'AuthFailure(${kind.name}): $reason';
  }
}

/// 인증 브라우저를 열어 [url] 로 보내고, [callbackUrlScheme] 콜백 URL 을 돌려받는다.
typedef BrowserAuthenticate =
    Future<String> Function({
      required String url,
      required String callbackUrlScheme,
    });

/// DataGSM 로그인과 Cowork 토큰 수명주기를 담당한다.
///
/// PKCE·state·nonce 는 cowork-authorization 이 만들고 검증한다(서버 관리 OAuth/OIDC).
/// 1. `/auth/authorize` 로 로그인 시도를 열어 인가 URL 과 로그인 시도 쿠키를 받는다.
/// 2. 인가 URL 을 브라우저로 열어 DataGSM 콜백을 받는다.
/// 3. 콜백의 `state`·`code` 를 쿠키와 함께 `/auth/callback` 에 넘겨 Cowork JWT 쌍을 받는다.
/// 4. refresh token 만 secure storage 에 남긴다. access token 은 30분짜리라 메모리로 충분하다.
class AuthRepository {
  AuthRepository({
    Dio? dio,
    FlutterSecureStorage? storage,
    BrowserAuthenticate? authenticate,
  }) : _dio = dio ?? createDio(ApiService.authorization),
       _storage = storage ?? const FlutterSecureStorage(),
       _authenticate = authenticate ?? FlutterWebAuth2.authenticate;

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final BrowserAuthenticate _authenticate;

  static const _refreshTokenKey = 'cowork.refresh_token';

  /// `/auth/authorize` 가 내려주는 로그인 시도 쿠키 이름의 앞부분. 서버는 동시 시도가
  /// 서로 덮어쓰지 않게 뒤에 state 해시를 붙인다(`__Host-cowork_oauth_<hash>`).
  /// `/auth/callback` 에서 이 쿠키로 서버에 저장된 state·nonce·code_verifier 를 찾는다.
  /// 1회용이고 10분 뒤 만료된다.
  static const _loginCookiePrefix = '__Host-cowork_oauth_';

  String? _accessToken;

  /// 진행 중인 갱신. 동시에 부른 쪽들이 갱신을 각자 보내지 않게 묶는다.
  Future<bool>? _restoring;

  /// 로그인·로그아웃을 시작할 때마다 올린다. 갱신을 보낼 때의 값과 응답을 받은 뒤의
  /// 값이 다르면 지난 세션의 응답이라 저장·삭제·알림을 하지 않는다.
  int _generation = 0;

  final _sessionExpired = StreamController<void>.broadcast();

  /// 인증이 필요한 API 호출에 붙일 Bearer 토큰. 로그아웃 상태면 null.
  String? get accessToken => _accessToken;

  /// 서버가 refresh token 을 거절해 세션이 끝났을 때 알린다.
  Stream<void> get sessionExpired => _sessionExpired.stream;

  /// 브라우저를 열어 DataGSM 로그인을 수행하고 토큰까지 발급받는다.
  ///
  /// 로그인 시도는 성공·실패와 관계없이 한 번 쓰면 서버에서 사라진다. 실패하면 다시
  /// 부를 때 새 시도를 연다.
  Future<void> signIn() async {
    _generation++;
    final start = await _dio.post<String>(
      '/auth/authorize',
      data: {'redirect_uri': DgsmOAuthConfig.redirectUri},
    );
    final authorizationUrl = unwrapPayload(
      start.data ?? '',
    )['authorization_url'];
    final cookie = _loginCookieOf(start.headers);
    // 쿠키 없이는 콜백을 서버가 받아 주지 않는다. 브라우저 로그인을 헛되이 시키지 않게
    // 여기서 멈춘다.
    if (authorizationUrl is! String || cookie == null) {
      throw const AuthFailure(AuthFailureKind.invalidLoginStart);
    }

    final String callback;
    try {
      callback = await _authenticate(
        url: authorizationUrl,
        callbackUrlScheme: DgsmOAuthConfig.callbackUrlScheme,
      );
    } on PlatformException catch (e, s) {
      // 원래 스택을 남겨야 로그에서 플러그인 쪽 원인을 따라갈 수 있다.
      Error.throwWithStackTrace(
        AuthFailure(
          e.code == 'CANCELED'
              ? AuthFailureKind.canceled
              : AuthFailureKind.browserFailed,
          cause: e,
        ),
        s,
      );
    }

    // state 는 서버가 쿠키로 찾은 값과 비교한다(CSRF 방어). 앱은 그대로 넘기기만 한다.
    // 빠져 있으면 서버가 거절할 게 정해져 있으니 보내지 않고 여기서 멈춘다. 거절 알림도
    // state 없이는 서버가 맞춰 볼 수 없어 보내지 않는다.
    final params = Uri.parse(callback).queryParameters;
    final state = params['state'];
    if (state == null || state.isEmpty) {
      throw const AuthFailure(AuthFailureKind.stateMissing);
    }
    final code = params['code'];
    if (code == null) {
      final error = params['error'];
      if (error != null) await _notifyLoginDenied(state, error, cookie);
      throw AuthFailure(
        AuthFailureKind.codeMissing,
        // 빈 사유는 없는 것으로 봐야 Bloc 의 기본 문구가 쓰인다.
        detail: [
          params['error_description'],
          params['error'],
        ].nonNulls.where((reason) => reason.isNotEmpty).firstOrNull,
      );
    }

    await _saveTokens(
      await _post('/auth/callback', {
        'state': state,
        'code': code,
      }, cookie: cookie),
    );
  }

  /// DataGSM 이 인가 코드 대신 오류를 돌려줬다고 서버에 알려 로그인 시도를 닫는다.
  ///
  /// 서버는 이 요청도 실패로 응답한다. 사용자에겐 서버 응답보다 DataGSM 사유가 더
  /// 정확하므로, 결과는 기다리기만 하고 실패해도 로그만 남긴다.
  Future<void> _notifyLoginDenied(
    String state,
    String error,
    String cookie,
  ) async {
    try {
      await _post('/auth/callback', {
        'state': state,
        'error': error,
      }, cookie: cookie);
    } catch (e, s) {
      Logger.e('로그인 거절 전달 실패', tag: 'Auth', error: e, stackTrace: s);
    }
  }

  /// 저장된 refresh token 으로 세션을 되살린다. 없거나 갱신에 실패하면 false.
  ///
  /// 앱 시작, API 401, 소켓 인증 실패가 모두 이걸 부르므로 동시에 불려도 갱신은 한
  /// 번만 보낸다. 서버가 refresh token 을 rotation 하면 동시에 보낸 갱신 중 하나가
  /// 이미 쓴 토큰으로 거절돼 세션이 지워질 수 있다.
  ///
  /// 서버가 refresh token 을 거절했을 때(400/401)만 토큰을 지우고 [sessionExpired] 로
  /// 알린다. 네트워크나 서버 장애로 실패하면 토큰을 남겨 다음 갱신 때 다시 시도한다.
  ///
  /// 응답을 기다리는 사이 로그아웃·재로그인했으면 그 응답은 버리고 false 를 준다.
  /// 늦게 온 성공이 지운 토큰을 되살리거나, 늦게 온 401 이 새 로그인 토큰을 지우지
  /// 않게 하려는 것이다.
  Future<bool> restoreSession() =>
      _restoring ??= _refresh().whenComplete(() => _restoring = null);

  Future<bool> _refresh() async {
    // 저장소를 읽는 사이에도 로그아웃이 끼어들 수 있어 읽기 전에 잡는다.
    final generation = _generation;

    // 세대 검사와 토큰 변경 사이에 await 가 끼면 그 틈에 다시 꼬이므로, 검사한 뒤
    // 곧바로 저장·삭제한다.
    try {
      // 저장소 읽기 실패(keystore 손상 등)도 여기서 false 로 끝내야 앱 시작이
      // 스플래시에서 멈추지 않는다.
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;
      final tokens = await _post('/auth/refresh', {
        'refresh_token': refreshToken,
      });
      if (generation != _generation) return false;
      await _saveTokens(tokens);
      return true;
    } catch (e, s) {
      // 인터셉터·소켓도 부르는 경로라 Bloc 이 대신 남겨 줄 수 없다.
      Logger.e('세션 복원 실패', tag: 'Auth', error: e, stackTrace: s);
      if (generation != _generation) return false;
      final status = e is DioException ? e.response?.statusCode : null;
      if (status == 400 || status == 401) {
        await _clear();
        _sessionExpired.add(null);
      }
      return false;
    }
  }

  Future<void> signOut() async {
    _generation++;
    final accessToken = _accessToken;

    // 서버 무효화가 어떻게 실패하든(응답 본문이 JSON 이 아닌 경우 포함) 로컬 토큰은
    // 반드시 지운다.
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken != null && accessToken != null) {
        await _post('/auth/signout', {
          'refresh_token': refreshToken,
        }, bearer: accessToken);
      }
    } catch (e, s) {
      Logger.e('서버 로그아웃 실패', tag: 'Auth', error: e, stackTrace: s);
    }
    await _clear();
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> body, {
    String? bearer,
    String? cookie,
  }) async {
    final response = await _dio.post<String>(
      path,
      data: body,
      options: Options(
        headers: {
          if (bearer != null) 'Authorization': 'Bearer $bearer',
          if (cookie != null) 'Cookie': cookie,
        },
      ),
    );
    return unwrapPayload(response.data ?? '');
  }

  /// 응답의 `Set-Cookie` 들에서 로그인 시도 쿠키를 `이름=값` 그대로 꺼낸다.
  ///
  /// ponytail: dio 는 쿠키를 저장하지 않는다. 로그인 한 번에만 쓰는 쿠키라 cookie_jar
  /// 를 들이지 않고 여기서 직접 넘긴다. 다른 API 도 쿠키가 필요해지면 그때 바꾼다.
  static String? _loginCookieOf(Headers headers) {
    for (final header in headers['set-cookie'] ?? const <String>[]) {
      final pair = header.split(';').first.trim();
      final separator = pair.indexOf('=');
      if (pair.startsWith(_loginCookiePrefix) &&
          separator > _loginCookiePrefix.length &&
          separator < pair.length - 1) {
        return pair;
      }
    }
    return null;
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final access = data['access_token'];
    final refresh = data['refresh_token'];
    if (access is! String || refresh is! String) {
      throw const AuthFailure(AuthFailureKind.invalidTokenResponse);
    }
    _accessToken = access;
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }

  Future<void> _clear() async {
    _accessToken = null;
    await _storage.delete(key: _refreshTokenKey);
  }
}
