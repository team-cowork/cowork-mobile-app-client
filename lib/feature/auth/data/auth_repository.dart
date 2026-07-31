import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../../core/utils/logger.dart';
import '../../../network/dio_client.dart';
import '../../../network/http_error_message.dart';
import 'dgsm_oauth_config.dart';

/// 사용자에게 그대로 보여줄 수 있는 로그인 실패 사유.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

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
    : _dio = dio ?? createDio(),
      _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const _refreshTokenKey = 'cowork.refresh_token';

  String? _accessToken;

  /// 인증이 필요한 API 호출에 붙일 Bearer 토큰. 로그아웃 상태면 null.
  String? get accessToken => _accessToken;

  /// 브라우저를 열어 DataGSM 로그인을 수행하고 토큰까지 발급받는다.
  Future<void> signIn() async {
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

  /// 저장된 refresh token 으로 세션을 되살린다. 없거나 만료됐으면 false.
  Future<bool> restoreSession() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return false;

    try {
      await _saveTokens(
        await _post('/auth/refresh', {'refresh_token': refreshToken}),
      );
      return true;
    } on AuthException catch (e) {
      Logger.e('세션 복원 실패', tag: 'Auth', error: e);
      await _clear();
      return false;
    }
  }

  Future<void> signOut() async {
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

/// dio 실패를 사용자에게 보여줄 문구로 바꾼다.
///
/// 응답이 있으면 서버가 거절한 것(4xx/5xx)이라 상태 코드와 서버 사유를 살리고,
/// 없으면 연결 자체가 안 된 것이라 코드를 붙일 게 없다.
@visibleForTesting
AuthException authExceptionOf(DioException e) {
  final failed = e.response;
  if (failed == null) return const AuthException('네트워크에 연결할 수 없습니다.');
  return AuthException(
    httpErrorMessage(
      failed.statusCode ?? 0,
      errorMessageOf(failed.data?.toString() ?? ''),
    ),
  );
}

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

/// 게이트웨이는 응답을 `{status, code, message, data}` 로 감싸고 서비스를 직접
/// 부르면 감싸지 않는다. 둘 다 받아준다. 본문 없는 204 는 빈 맵.
@visibleForTesting
Map<String, dynamic> unwrapPayload(String body) {
  if (body.isEmpty) return const {};
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) return const {};
  final data = decoded['data'];
  return data is Map<String, dynamic> ? data : decoded;
}

/// DataGSM(`error_description`)과 게이트웨이(`message`) 양쪽 오류 형식을 읽는다.
@visibleForTesting
String? errorMessageOf(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      final message = decoded['error_description'] ?? decoded['message'];
      if (message is String && message.isNotEmpty) return message;
    }
  } catch (_) {
    // 오류 본문이 JSON 이 아니면 호출부의 기본 메시지를 쓴다.
  }
  return null;
}
