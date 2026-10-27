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

  NotificationItem copyWith({bool? isUnread}) => NotificationItem(
    id: id,
    title: title,
    description: description,
    time: time,
    isUnread: isUnread ?? this.isUnread,
    avatarInitial: avatarInitial,
    avatarColor: avatarColor,
    icon: icon,
  );

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
  ];
}
