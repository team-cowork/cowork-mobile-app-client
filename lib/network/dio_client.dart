import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../feature/auth/data/dgsm_oauth_config.dart';

/// Cowork API 게이트웨이를 향하는 dio 인스턴스를 만든다.
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
