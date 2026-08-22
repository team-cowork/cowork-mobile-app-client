import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/chat_message.dart';
import '../../domain/enums/chat_avatar_color.dart';

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

  static Color _colorFor(ChatAvatarColor color) => switch (color) {
    ChatAvatarColor.blue => AppColors.blue500,
    ChatAvatarColor.green => AppColors.green500,
    ChatAvatarColor.amber => AppColors.amber500,
    ChatAvatarColor.red => AppColors.red400,
    ChatAvatarColor.neutral => AppColors.neutral700,
  };

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
        backgroundColor: _colorFor(message.avatarColor),
        foregroundColor: AppColors.white,
      ),
    );

    if (onTap == null) return item;
    return InkWell(onTap: onTap, child: item);
  }
}
