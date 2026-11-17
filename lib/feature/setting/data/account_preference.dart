import '../domain/enums/notification_level.dart';

/// `GET/PUT /preferences/account/{id}` 의 계정 설정 중 앱이 쓰는 값.
///
/// 서버는 PUT 에서 보낸 항목만 바꾸고 생략한 항목은 유지한다. 그래서 화면이 다루지
/// 않는 필드(`theme`, `timezone`, `dnd_schedule` 등)를 들고 있다가 되돌려 보낼
/// 필요가 없다.
class AccountPreference {
  const AccountPreference({required this.notificationLevel});

  factory AccountPreference.fromJson(Map<String, dynamic> json) =>
      AccountPreference(
        notificationLevel: NotificationLevel.fromValue(
          json['notification_level'] as String?,
        ),
      );

  final NotificationLevel notificationLevel;
}
