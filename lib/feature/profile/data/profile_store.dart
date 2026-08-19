/// 로그인 사용자의 인메모리 캐시.
///
/// 프로필은 `/users/me` 가 원본이고([ProfileRepository]), 여기엔 회의록 작성자에
/// 필요한 최소한만 남긴다. 회의록 화면이 프로필 응답을 다시 부르지 않게 하는 게 목적.
///
// ponytail: 앱 재시작 시 초기화됨. 아래 기본값은 프로필 화면에 한 번도 들어가지
// 않고 회의록부터 쓸 때만 보이는 목 값이다. 회의록이 서버로 붙으면 같이 사라진다.
class ProfileStore {
  ProfileStore._();

  static final ProfileStore instance = ProfileStore._();

  /// 현재 로그인 사용자 id. 회의록 소유 판별(내 노트인지)에 쓰인다.
  int currentUserId = 1;

  String name = '김준혁';
  String avatarUrl = 'https://avatars.githubusercontent.com/u/0';
  String avatarInitial = '준';

  /// 편집 화면에서 고른 프로필 사진 경로. 없으면 [avatarUrl]을 사용한다.
  ///
  /// 저장하면 서버로 올라가고 이 값은 비워진다. 업로드에 실패했을 때만 남아서,
  /// 서버에 아직 없는 사진을 화면에 계속 보여주는 역할을 한다.
  String? localAvatarPath;
}
