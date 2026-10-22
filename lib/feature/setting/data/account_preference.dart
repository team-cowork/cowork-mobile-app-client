import '../domain/enums/notification_level.dart';

/// `GET/PUT /preferences/account/{id}` 의 계정 설정.
///
/// 받은 JSON 을 통째로 들고 있다가 바꾼 필드만 덮어 그대로 돌려보낸다. 스펙만으로는
/// PUT 이 전체 교체인지 부분 수정인지 알 수 없어서, 어느 쪽이든 화면이 다루지 않는
/// 필드(`theme`, `timezone`, `dnd_schedule` 등)가 지워지지 않게 하려는 것이다.
class AccountPreference {
  const AccountPreference(this._json);

  factory AccountPreference.fromJson(Map<String, dynamic> json) =>
      AccountPreference(Map.unmodifiable(json));

  final Map<String, dynamic> _json;

  NotificationLevel get notificationLevel =>
      NotificationLevel.fromValue(_json['notification_level'] as String?);

  AccountPreference withNotificationLevel(NotificationLevel level) =>
      AccountPreference(
        Map.unmodifiable({..._json, 'notification_level': level.value}),
      );

  Map<String, dynamic> toJson() => _json;
}
