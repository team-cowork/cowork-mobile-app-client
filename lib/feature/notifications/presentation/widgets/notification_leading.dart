import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/avatar_color.dart';
import '../../domain/enums/notification_icon_type.dart';
import '../../domain/notification_item.dart';

class NotificationLeading extends StatelessWidget {
  const NotificationLeading({super.key, required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final initial = item.avatarInitial;
    if (initial != null) {
      return CoworkAvatar(
        initials: initial,
        size: 40,
        backgroundColor: _avatarColor(item.avatarColor!),
        foregroundColor: AppColors.white,
      );
    }

    final icon = item.icon!;
    final tint = _iconTint(icon);
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: _iconFor(icon),
    );
  }

  static Color _avatarColor(AvatarColor color) => switch (color) {
    AvatarColor.green => AppColors.green500,
    AvatarColor.amber => AppColors.amber500,
    AvatarColor.blue => AppColors.blue500,
    AvatarColor.red => AppColors.red400,
  };

  static Color _iconTint(NotificationIconType icon) => switch (icon) {
    NotificationIconType.taskAssigned => AppColors.blue500,
    NotificationIconType.gitPush => AppColors.green500,
  };

  static Widget _iconFor(NotificationIconType icon) => switch (icon) {
    NotificationIconType.taskAssigned => AppIcon.taskAssigned(size: 20),
    NotificationIconType.gitPush => AppIcon.gitPush(size: 20),
  };
}
