import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/http_error_message.dart';
import '../../../core/utils/logger.dart';
import 'dgsm_oauth_config.dart';

/// 사용자에게 그대로 보여줄 수 있는 로그인 실패 사유.
class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode});

  final String message;

  /// 서버가 거절했을 때의 HTTP 상태 코드. 연결 자체가 안 됐으면 null.
  final int? statusCode;

  @override
  String toString() => 'AuthException: $message';
}

/// DataGSM OAuth(PKCE) 로그인과 Cowork 토큰 수명주기를 담당한다.
///
/// 1. DataGSM `authorize` 를 브라우저로 열어 인가 코드를 받는다.
/// 2. `code` + `code_verifier` 를 cowork-authorization 에 넘겨 Cowork JWT 쌍을 받는다.
/// 3. refresh token 만 secure storage 에 남긴다. access token 은 30분짜리라 메모리로 충분하다.
class AuthRepository {
  AuthRepository({Dio? dio, FlutterSecureStorage? storage})
    : _dio = dio ?? createDio(ApiService.authorization),
      _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const _refreshTokenKey = 'cowork.refresh_token';

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
  Future<void> signIn() async {
    _generation++;
    final verifier = createCodeVerifier();
    final state = createCodeVerifier(16);

    final url = Uri.parse(DgsmOAuthConfig.authorizeEndpoint).replace(
      queryParameters: {
        'client_id': DgsmOAuthConfig.clientId,
        'redirect_uri': DgsmOAuthConfig.redirectUri,
        'response_type': 'code',
        'code_challenge': codeChallengeOf(verifier),
        'code_challenge_method': 'S256',
        'state': state,
      },
    );

    final String callback;
    try {
      callback = await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: DgsmOAuthConfig.callbackUrlScheme,
      );
    } on PlatformException catch (e, s) {
      Logger.e('브라우저 인증 실패', tag: 'Auth', error: e, stackTrace: s);
      throw AuthException(
        e.code == 'CANCELED' ? '로그인이 취소되었습니다.' : '브라우저 인증에 실패했습니다.',
      );
    }

    final params = Uri.parse(callback).queryParameters;
    // CSRF: 우리가 보낸 state 가 그대로 돌아왔을 때만 인가 코드를 신뢰한다.
    if (params['state'] != state) {
      throw const AuthException('인증 응답을 신뢰할 수 없어 로그인을 중단했습니다.');
    }
    final code = params['code'];
    if (code == null) {
      throw AuthException(
        params['error_description'] ?? params['error'] ?? '인가 코드를 받지 못했습니다.',
      );
    }

    await _saveTokens(
      await _post('/auth/token', {
        'code': code,
        'code_verifier': verifier,
        'redirect_uri': DgsmOAuthConfig.redirectUri,
      }),
    );
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
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return false;

    // 세대 검사와 토큰 변경 사이에 await 가 끼면 그 틈에 다시 꼬이므로, 검사한 뒤
    // 곧바로 저장·삭제한다.
    try {
      final tokens = await _post('/auth/refresh', {
        'refresh_token': refreshToken,
      });
      if (generation != _generation) return false;
      await _saveTokens(tokens);
      return true;
    } on AuthException catch (e) {
      Logger.e('세션 복원 실패', tag: 'Auth', error: e);
      if (generation != _generation) return false;
      if (e.statusCode == 400 || e.statusCode == 401) {
        await _clear();
        _sessionExpired.add(null);
      }
      return false;
    }
  }

  Future<void> signOut() async {
    _generation++;
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final accessToken = _accessToken;

    if (refreshToken != null && accessToken != null) {
      try {
        await _post('/auth/signout', {
          'refresh_token': refreshToken,
        }, bearer: accessToken);
      } on AuthException catch (e) {
        // 서버 무효화에 실패해도 로컬 토큰은 반드시 지운다.
        Logger.e('서버 로그아웃 실패', tag: 'Auth', error: e);
      }
    }
    await _clear();
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> body, {
    String? bearer,
  }) async {
    final Response<String> response;
    try {
      response = await _dio.post<String>(
        path,
        data: body,
        options: bearer == null
            ? null
            : Options(headers: {'Authorization': 'Bearer $bearer'}),
      );
    } on DioException catch (e, s) {
      // 서버가 거절한 건 사용자 문구로 충분하고, 못 붙은 건 원인을 남겨야 한다.
      if (e.response == null) {
        Logger.e('$path 요청 실패', tag: 'Auth', error: e, stackTrace: s);
      }
      throw authExceptionOf(e);
    }

    return unwrapPayload(response.data ?? '');
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final access = data['access_token'];
    final refresh = data['refresh_token'];
    if (access is! String || refresh is! String) {
      throw const AuthException('토큰 응답 형식이 올바르지 않습니다.');
    }
    _accessToken = access;
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }

  Future<void> _clear() async {
    _accessToken = null;
    await _storage.delete(key: _refreshTokenKey);
  }
}

/// dio 실패를 로그인 화면이 보여줄 예외로 바꾼다. 문구는 공통 규칙을 따른다.
@visibleForTesting
AuthException authExceptionOf(DioException e) =>
    AuthException(dioErrorMessage(e), statusCode: e.response?.statusCode);

/// RFC 7636 code_verifier. [bytes] 32개면 43자로 규격(43~128자)에 들어맞는다.
@visibleForTesting
String createCodeVerifier([int bytes = 32]) {
  final random = Random.secure();
  return _base64UrlNoPad(List<int>.generate(bytes, (_) => random.nextInt(256)));
}

/// RFC 7636 S256 challenge: base64url(sha256(ascii(verifier))), 패딩 제거.
@visibleForTesting
String codeChallengeOf(String verifier) =>
    _base64UrlNoPad(sha256.convert(ascii.encode(verifier)).bytes);

String _base64UrlNoPad(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');
