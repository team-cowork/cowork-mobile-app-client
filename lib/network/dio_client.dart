import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../feature/auth/data/auth_repository.dart';
import '../feature/auth/data/dgsm_oauth_config.dart';
import 'auth_interceptor.dart';

/// Cowork API 게이트웨이를 향하는 dio 인스턴스를 만든다.
///
/// 인증 헤더는 붙지 않는다. `/auth/*` 를 부르는 [AuthRepository] 전용이고, 그 밖의
/// API 는 [createAuthedDio] 를 쓴다.
///
/// 저장소마다 각자 `Dio()` 를 세우면 baseUrl 과 로깅 설정이 갈라지므로 여기로 모은다.
Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: DgsmOAuthConfig.apiBaseUrl,
      contentType: Headers.jsonContentType,
      // 본문을 문자열 그대로 받는다. 응답을 벗겨내는 쪽이 raw JSON 을 파싱하는 구조라
      // dio 의 자동 디코딩을 끄는 편이 분기가 하나 줄어든다.
      responseType: ResponseType.plain,
    ),
  );
  // ponytail: 본문과 헤더는 일부러 뺐다. 요청 본문엔 code_verifier / refresh_token 이,
  // 헤더엔 Bearer 토큰이 들어 있어 logcat 에 그대로 남는다. 본문까지 봐야 하는
  // 순간이 오면 그때만 requestBody 를 잠깐 켜고 되돌린다.
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
      ),
    );
  }
  return dio;
}

/// 인증이 필요한 API 용 dio. access token 을 붙이고 401 이면 갱신해 재시도한다.
///
/// 갱신은 [AuthRepository.restoreSession] 이 그대로 맡는다. 저장된 refresh token 으로
/// 새 토큰을 받아오고, 실패하면 로컬 토큰까지 지워 로그아웃 상태로 눕히는 동작이
/// 앱 시작 시 복원과 똑같기 때문이다.
Dio createAuthedDio(AuthRepository repository) {
  final dio = createDio();
  dio.interceptors.add(
    AuthInterceptor(
      client: dio,
      accessToken: () => repository.accessToken,
      refresh: repository.restoreSession,
    ),
  );
  return dio;
}

/// 게이트웨이는 응답을 `{status, code, message, data}` 로 감싸고 서비스를 직접
/// 부르면 감싸지 않는다. 둘 다 받아준다. 본문 없는 204 는 빈 맵.
///
/// 저장소마다 이 분기를 다시 쓰지 않도록 네트워크 공통 모듈에 둔다.
Map<String, dynamic> unwrapPayload(String body) {
  if (body.isEmpty) return const {};
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) return const {};
  final data = decoded['data'];
  return data is Map<String, dynamic> ? data : decoded;
}
