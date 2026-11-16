/// DataGSM 로그인 및 Cowork 인증 API 설정값.
///
/// 값은 `--dart-define-from-file=.env` 로 주입한다. flutter_dotenv 같은 런타임
/// 로더를 쓰지 않는 이유는 dart-define 이 SDK 기본 기능이고, .env 를 asset 으로
/// 번들하지 않아도 되기 때문이다.
///
/// ponytail: client id·인가 주소·PKCE 는 앱이 모른다. cowork-authorization 이
/// `/auth/authorize` 에서 인가 URL 을 만들어 주고 `/auth/callback` 에서 검증한다.
abstract final class DgsmOAuthConfig {
  /// DataGSM 이 로그인 결과를 돌려보낼 콜백. DataGSM 앱 등록값과 서버 허용 목록
  /// (`DATAGSM_REDIRECT_URIS`)에 똑같이 있어야 `/auth/authorize` 가 받아 준다.
  static const String redirectUri = String.fromEnvironment(
    'DGSM_REDIRECT_URI',
    defaultValue: 'cowork://oauth/callback',
  );

  /// [redirectUri] 의 scheme. flutter_web_auth_2 가 콜백을 가로챌 때 쓴다.
  /// AndroidManifest 의 `CallbackActivity` intent-filter scheme 과 같아야 한다.
  static String get callbackUrlScheme => Uri.parse(redirectUri).scheme;

  /// Cowork API 게이트웨이. 토큰 발급/갱신/로그아웃은 전부 여기로 간다.
  ///
  /// 기본값을 두지 않는다. 개발/운영 서버가 갈리는 값이라 기본값을 박아두면
  /// 릴리스 빌드가 조용히 개발 서버를 가리킨다. 빌드마다 명시적으로 주입한다.
  /// (웹 클라이언트도 `NEXT_PUBLIC_BASE_URL` 을 빈 값으로 두고 주입을 강제한다.)
  static const String apiBaseUrl = String.fromEnvironment(
    'COWORK_API_BASE_URL',
  );

  /// dart-define 없이 실행하면 [apiBaseUrl] 이 빈 문자열이라 요청이 조용히
  /// 실패한다. 앱 진입 시점에 바로 터지게 한다.
  ///
  /// ponytail: assert 라 디버그 빌드에서만 잡힌다. 릴리스 빌드에 define 을
  /// 빠뜨리는 건 CI 에서 막을 문제라 런타임 검사로 승격하지 않는다.
  static void assertConfigured() {
    assert(
      apiBaseUrl.isNotEmpty,
      'COWORK_API_BASE_URL 이 비어 있습니다. '
      '.env.example 를 .env 로 복사한 뒤 '
      'flutter run --dart-define-from-file=.env 로 실행하세요.',
    );
  }
}
