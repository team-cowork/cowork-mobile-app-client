import 'package:equatable/equatable.dart';

/// 설정 화면에서 사용하는 도메인 모델.
///
/// 토글/표시 값만 담는다. 실제 저장·연동은 Bloc 쪽에서 처리한다.
class Settings extends Equatable {
  const Settings({
    required this.linkedAccount,
    required this.pushNotification,
    required this.mentionOnly,
    required this.darkMode,
    required this.commitStreakPublic,
    required this.version,
  });

  /// 연동된 계정 라벨 (예: DataGSM).
  final String linkedAccount;

  /// 푸시 알림 수신 여부.
  final bool pushNotification;

  /// 멘션만 받기 여부.
  final bool mentionOnly;

  /// 다크 모드 여부.
  final bool darkMode;

  /// GitHub 커밋 스트릭 공개 여부.
  final bool commitStreakPublic;

  /// 앱 버전 (예: 1.0.0).
  final String version;

  Settings copyWith({
    String? linkedAccount,
    bool? pushNotification,
    bool? mentionOnly,
    bool? darkMode,
    bool? commitStreakPublic,
    String? version,
  }) {
    return Settings(
      linkedAccount: linkedAccount ?? this.linkedAccount,
      pushNotification: pushNotification ?? this.pushNotification,
      mentionOnly: mentionOnly ?? this.mentionOnly,
      darkMode: darkMode ?? this.darkMode,
      commitStreakPublic: commitStreakPublic ?? this.commitStreakPublic,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
    linkedAccount,
    pushNotification,
    mentionOnly,
    darkMode,
    commitStreakPublic,
    version,
  ];
}
