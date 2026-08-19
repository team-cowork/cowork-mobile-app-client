import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'chat_button.dart';

class ChatShortcutBar extends StatelessWidget {
  const ChatShortcutBar({super.key});

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
            CoworkIconButton.custom(icon: AppIcon.plus()),
            ChatButton(onTap: () {}),
          ],
        ),
      ),
    );
  }
}
