import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/workspace_shortcut.dart';
import 'workspace_shortcut_button.dart';

class ChatShortcutBar extends StatelessWidget {
  const ChatShortcutBar({
    super.key,
    required this.shortcuts,
    this.onDmHomeTap,
  });

  final List<WorkspaceShortcut> shortcuts;
  final VoidCallback? onDmHomeTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s4,
          AppSpacing.s16,
          AppSpacing.s14,
        ),
        child: Row(
          spacing: 14,
          children: [
            GestureDetector(
              onTap: onDmHomeTap,
              child: Container(
                width: AppSize.componentLarge,
                height: AppSize.componentLarge,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.neutral750,
                  shape: BoxShape.circle,
                ),
                child: AppIcon.dmHome(),
              ),
            ),
            for (final shortcut in shortcuts)
              WorkspaceShortcutButton(shortcut: shortcut, onTap: () {}),
            CoworkIconButton.custom(icon: AppIcon.plus()),
          ],
        ),
      ),
    );
  }
}
