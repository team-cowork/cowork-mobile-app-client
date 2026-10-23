import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/chat_avatar_color_mapping.dart';
import '../../domain/chat_message.dart';

class ChatMessageRow extends StatelessWidget {
  const ChatMessageRow({
    required this.message,
    this.avatarSize = AppSize.componentMedium,
    this.onTap,
    super.key,
  });

  final ChatMessage message;
  final double avatarSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final item = CoworkMessageItem(
      username: message.author.name,
      timestamp: message.timestamp,
      message: message.text,
      initials: message.author.avatarInitial,
      avatar: CoworkAvatar(
        initials: message.author.avatarInitial,
        size: avatarSize,
        backgroundColor: message.avatarColor.toColor(),
        foregroundColor: AppColors.white,
      ),
    );

    if (onTap == null) return item;
    return InkWell(onTap: onTap, child: item);
  }
}
