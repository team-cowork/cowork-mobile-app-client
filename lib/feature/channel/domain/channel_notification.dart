import 'package:equatable/equatable.dart';

import '../../setting/domain/enums/notification_level.dart';

/// 내가 이 채널에 정해 둔 알림 설정.
class ChannelNotification extends Equatable {
  const ChannelNotification({this.level, this.mutedUntil});

  /// 채널에 정한 알림 수준. null 이면 정하지 않아 계정·팀 설정을 따른다(서버 `DEFAULT`).
  final NotificationLevel? level;

  /// 이 시각까지 알림을 끈다. 없으면 끄지 않았다.
  final DateTime? mutedUntil;

  /// [now] 에 알림이 꺼져 있는지.
  bool isMuted(DateTime now) => mutedUntil?.isAfter(now) ?? false;

  @override
  List<Object?> get props => [level, mutedUntil];
}
