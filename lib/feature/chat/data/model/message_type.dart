/// 서버(cowork-chat) 메시지의 `type` 값.
///
/// 서버 값이라 오타가 나면 조용히 다른 형식으로 다뤄지므로 한 곳에만 둔다.
abstract final class MessageType {
  /// 파일이 붙은 메시지. 본문은 비어도 된다.
  static const file = 'FILE';

  /// 서버가 남기는 안내 메시지(입장·퇴장 등).
  static const system = 'SYSTEM';
}
