/// DGSM OAuth(PKCE) 및 Cowork 인증 API 설정값.
///
/// 값은 `--dart-define-from-file=.env` 로 주입한다. flutter_dotenv 같은 런타임
/// 로더를 쓰지 않는 이유는 dart-define 이 SDK 기본 기능이고, .env 를 asset 으로
/// 번들하지 않아도 되기 때문이다.
///
/// ponytail: client_secret 은 없다. 인가 코드를 DataGSM 토큰으로 바꾸는 일은 앱이
/// 아니라 cowork-authorization 이 한다(`POST /auth/token`). 앱은 code 와
/// code_verifier 만 넘기고 Cowork JWT 쌍을 돌려받는다.
abstract final class DgsmOAuthConfig {
  /// 데스크톱 클라이언트와 공유하는 public client id.
  /// PKCE 공개 클라이언트라 노출돼도 무방하다. (cowork-desktop-app-client AppConfig 참고)
  static const String clientId = String.fromEnvironment(
    'DGSM_CLIENT_ID',
    defaultValue: 'e7cbba21-deb8-41a2-8648-f9a2234b343f',
  );

  static const String redirectUri = String.fromEnvironment(
    'DGSM_REDIRECT_URI',
    defaultValue: 'cowork://oauth/callback',
  );

  /// [redirectUri] 의 scheme. flutter_web_auth_2 가 콜백을 가로챌 때 쓴다.
  /// AndroidManifest 의 `CallbackActivity` intent-filter scheme 과 같아야 한다.
  static String get callbackUrlScheme => Uri.parse(redirectUri).scheme;

  static const String authorizeEndpoint =
      'https://oauth.authorization.datagsm.kr/v1/oauth/authorize';

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
