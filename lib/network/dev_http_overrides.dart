import 'dart:io';

import 'package:flutter/foundation.dart';

import '../feature/auth/data/dgsm_oauth_config.dart';

/// 개발 API 서버가 자체 서명 인증서를 쓰는 동안만 TLS 검증을 통과시킨다.
///
/// Dart 의 `HttpClient` 는 Android 시스템 신뢰 저장소가 아니라 SDK 에 내장된 루트
/// 목록을 보기 때문에, 에뮬레이터에 루트 인증서를 설치해도 `HandshakeException`
/// 이 난다. 그래서 클라이언트에서 뚫는 것 말고는 방법이 없다.
///
/// ponytail: 임시 조치다. 서버에 정식 인증서가 깔리면 이 파일과 `main()` 의 호출을
/// 통째로 지운다. 그때까지 릴리스 빌드로 새지 않도록 [installIfDebug] 의
/// `kDebugMode` 와 호스트 일치를 **둘 다** 요구한다. 한쪽만으로는 부족하다.
/// 디버그 빌드로 개발 서버에 붙는 동안은 MITM 에 그대로 노출된다는 뜻이기도 하다.
class DevHttpOverrides extends HttpOverrides {
  /// [allowedHost] 를 비우면 `COWORK_API_BASE_URL` 의 호스트를 쓴다.
  DevHttpOverrides({String? allowedHost})
    : _allowedHost = allowedHost ?? Uri.parse(DgsmOAuthConfig.apiBaseUrl).host;

  final String _allowedHost;

  /// 디버그 빌드에서만 전역 오버라이드를 건다. 릴리스에서는 아무 일도 하지 않는다.
  static void installIfDebug() {
    if (kDebugMode) HttpOverrides.global = DevHttpOverrides();
  }

  /// 개발 서버 호스트가 아니면 평소대로 검증에 실패시킨다.
  @visibleForTesting
  bool allowsBadCertificateFor(String host) =>
      _allowedHost.isNotEmpty && host == _allowedHost;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..badCertificateCallback = (_, host, _) =>
            allowsBadCertificateFor(host);
}
