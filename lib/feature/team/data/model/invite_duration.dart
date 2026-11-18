/// 초대 코드 유효 기간. team 서비스 `POST /teams/{teamId}/invites` 의 `duration` 값이다.
///
/// 어떤 기간을 줄지는 서버가 정하는 API 계약이라 domain 이 아니라 data 에 둔다. 값은
/// 서버 OpenAPI 의 `CreateInviteRequest.duration` enum 과 같고, 웹 초대 화면과 같은
/// 순서로 둔다.
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
