/// 앱이 화면을 가를 때 보는 팀 권한. (팀에서 내가 할 수 있는 일)
///
/// 서버 역할은 팀마다 권한을 바꿀 수 있어서 역할 이름(OWNER/ADMIN/MEMBER)으로는 알 수
/// 없고, 내 역할들의 권한을 읽어 정한다. 서버 권한 키와의 대응은 data 계층이 맡는다.
enum TeamPermission {
  /// 팀 이름·설명·아이콘 수정.
  manageTeam,

  /// 팀 삭제.
  deleteTeam,

  /// 초대 코드 만들기·목록·무효화, 사람 바로 초대.
  manageInvites,

  /// 채널 만들기.
  manageChannels,

  /// 프로젝트(채널 카테고리) 만들기.
  manageProjects,
}
