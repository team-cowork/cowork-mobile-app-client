/// 초대 코드 유효 기간. team 서비스의 `duration` 값이다.
///
/// 웹 초대 화면과 같은 네 가지를 같은 순서로 둔다.
enum InviteDuration {
  oneDay('1d'),
  sevenDays('7d'),
  thirtyDays('30d'),
  never('never');

  const InviteDuration(this.value);

  final String value;

  /// 모르는 값이 오면 null. 서버가 기간을 늘려도 목록을 읽는 데는 지장이 없게 한다.
  static InviteDuration? fromValue(String? value) =>
      values.where((d) => d.value == value).firstOrNull;
}
