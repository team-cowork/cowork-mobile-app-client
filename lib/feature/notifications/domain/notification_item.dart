import 'package:equatable/equatable.dart';

import 'enums/avatar_color.dart';
import 'enums/notification_icon_type.dart';

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isUnread,
    this.avatarInitial,
    this.avatarColor,
    this.icon,
    this.channelId,
    this.teamId,
  }) : assert(
         (avatarInitial != null) != (icon != null),
         'avatarInitial 또는 icon 중 하나만 지정해야 한다',
       );

  final String id;
  final String title;
  final String description;
  final String time;
  final bool isUnread;

  final String? avatarInitial;
  final AvatarColor? avatarColor;
  final NotificationIconType? icon;

  /// 누르면 갈 채널. 없으면 null.
  final int? channelId;

  /// 채널이 없을 때 누르면 갈 팀. DM 이거나 갈 수 없는 팀(빠진 팀 등)이면 null.
  final int? teamId;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    time,
    isUnread,
    avatarInitial,
    avatarColor,
    icon,
    channelId,
    teamId,
  ];
}
