/// 채널 종류. 아이콘·표시 방식은 프레젠테이션 쪽에서 매핑한다.
enum ChannelType {
  /// 채팅
  chat,

  /// 깃허브 웹훅
  webhook,

  /// 파일
  file,

  /// 계정 공유
  accountShare,

  /// 회의록
  meetingNote,

  /// 음성
  voice,
}
