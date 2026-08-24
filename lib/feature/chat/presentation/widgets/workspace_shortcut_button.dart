import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/workspace_avatar_color.dart';
import '../../domain/workspace_shortcut.dart';

class WorkspaceShortcutButton extends StatelessWidget {
  const WorkspaceShortcutButton({super.key, required this.shortcut, this.onTap});

  final WorkspaceShortcut shortcut;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSize.componentLarge,
        height: AppSize.componentLarge,
        padding: shortcut.isSelected ? const EdgeInsets.all(2) : EdgeInsets.zero,
        decoration: shortcut.isSelected
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.red300, width: 2),
              )
            : null,
        child: CoworkAvatar(
          initials: shortcut.initial,
          size: shortcut.isSelected ? AppSize.componentLarge - 4 : AppSize.componentLarge,
          backgroundColor: _backgroundColor(shortcut.color),
          foregroundColor: AppColors.white,
        ),
      ),
    );
  }

  static Color _backgroundColor(WorkspaceAvatarColor color) => switch (color) {
    WorkspaceAvatarColor.neutral => AppColors.neutral750,
    WorkspaceAvatarColor.red => AppColors.red400,
    WorkspaceAvatarColor.blue => AppColors.blue500,
    WorkspaceAvatarColor.green => AppColors.green500,
  };
}
