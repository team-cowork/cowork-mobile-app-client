import 'package:equatable/equatable.dart';

import 'enums/notification_level.dart';

/// 설정 화면에서 사용하는 도메인 모델.
///
/// 토글/표시 값만 담는다. 실제 저장·연동은 Bloc 쪽에서 처리한다.
class Settings extends Equatable {
  const Settings({
    required this.linkedAccount,
    required this.notificationLevel,
    required this.commitStreakPublic,
    required this.version,
  });

  /// 연동된 계정 라벨 (예: DataGSM).
  final String linkedAccount;

  /// 서버의 계정 알림 수준. 푸시·멘션 토글 둘 다 여기서 나온다.
  final NotificationLevel notificationLevel;

  /// GitHub 커밋 스트릭 공개 여부.
  final bool commitStreakPublic;

  /// 앱 버전 (예: 1.0.0).
  final String version;

  /// 푸시 알림 수신 여부.
  bool get pushNotification => notificationLevel.pushEnabled;

  /// 멘션만 받기 여부.
  bool get mentionOnly => notificationLevel.mentionOnly;

  Settings copyWith({
    String? linkedAccount,
    NotificationLevel? notificationLevel,
    bool? commitStreakPublic,
    String? version,
  }) {
    return Settings(
      linkedAccount: linkedAccount ?? this.linkedAccount,
      notificationLevel: notificationLevel ?? this.notificationLevel,
      commitStreakPublic: commitStreakPublic ?? this.commitStreakPublic,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
    linkedAccount,
    notificationLevel,
    commitStreakPublic,
    version,
  ];
}
