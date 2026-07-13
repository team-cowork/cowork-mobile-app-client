/// 프로필 화면과 편집 화면이 공유하는 로컬(인메모리) 저장소.
///
/// 백엔드 연동 전까지 편집 → 저장 결과를 앱 세션 동안 유지한다.
/// 실제 API 연동 시 이 싱글턴을 리포지토리로 교체한다.
///
// ponytail: 앱 재시작 시 초기화됨. 영구 저장이 필요하면 shared_preferences로 승격.
class ProfileStore {
  ProfileStore._();

  static final ProfileStore instance = ProfileStore._();

  String name = '김준혁';
  String username = '@joon_hyeok0204';
  String statusMessage = '';
  String bio = '백엔드 개발자 · GSM 2학년 3반. 실서비스 트러블슈팅을 좋아합니다.';
  String avatarUrl = 'https://avatars.githubusercontent.com/u/0';
  String avatarInitial = '준';

  /// 로컬에서 선택한 프로필 사진 경로. 없으면 [avatarUrl]을 사용한다.
  String? localAvatarPath;
}
