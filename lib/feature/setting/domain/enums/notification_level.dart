/// 계정 기본 알림 수준. preference 서비스의 `notification_level` 값이다.
///
/// 화면은 이 값 하나를 `푸시 알림` / `멘션만 받기` 두 토글로 나눠 보여 준다.
/// 푸시가 꺼지면([none]) 멘션 설정을 담을 자리가 없어 멘션 토글은 비활성이 된다.
enum NotificationLevel {
  all('ALL'),
  mentions('MENTIONS'),
  none('NONE');

  const NotificationLevel(this.value);

  final String value;

  /// 모르는 값이 오면 알림을 끈 쪽으로 보지 않고 [all] 로 둔다. 서버가 값을 늘려도
  /// 사용자가 받던 알림이 화면에서 꺼진 것처럼 보이지 않게 하려는 것이다.
  static NotificationLevel fromValue(String? value) =>
      values.firstWhere((l) => l.value == value, orElse: () => all);

  /// `ALL` 과 `MENTIONS` 는 둘 다 푸시를 받는 상태다.
  bool get pushEnabled => this != none;

  bool get mentionOnly => this == mentions;
}
