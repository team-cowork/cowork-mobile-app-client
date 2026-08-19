/// 로그인 사용자의 인메모리 캐시.
///
/// 프로필은 `/users/me` 가 원본이고([ProfileRepository]), 여기엔 회의록 작성자에
/// 필요한 최소한만 남긴다. 회의록 화면이 프로필 응답을 다시 부르지 않게 하는 게 목적.
///
// ponytail: 앱 재시작 시 초기화됨. 로그인 직후 [ProfileRepository.fetchMe] 가 채운다.
// 아래 이름·사진 기본값은 그 응답이 오기 전 잠깐만 보이는 목 값이다.
class ProfileStore {
  ProfileStore._();

  static final ProfileStore instance = ProfileStore._();

  /// 현재 로그인 사용자 id. 회의록 소유 판별(내 노트인지)에 쓰인다.
  ///
  /// 아직 못 읽었으면 null 이다. 아무 id 나 넣어 두면 남의 회의록을 내 것으로 본다.
  int? currentUserId;

  String name = '김준혁';
  String avatarUrl = 'https://avatars.githubusercontent.com/u/0';
  String avatarInitial = '준';

  /// 편집 화면에서 고른 프로필 사진 경로. 없으면 [avatarUrl]을 사용한다.
  ///
  /// 저장하면 서버로 올라가고 이 값은 비워진다. 업로드에 실패했을 때만 남아서,
  /// 서버에 아직 없는 사진을 화면에 계속 보여주는 역할을 한다.
  String? localAvatarPath;
}
