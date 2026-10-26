import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/chat_avatar_color_mapping.dart';
import '../../domain/chat_attachment.dart';
import '../../domain/chat_message.dart';

class ChatMessageRow extends StatelessWidget {
  const ChatMessageRow({
    required this.message,
    this.avatarSize = AppSize.componentMedium,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final ChatMessage message;
  final double avatarSize;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    Widget item = CoworkMessageItem(
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

    if (message.attachments.isNotEmpty) {
      item = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item,
          Padding(
            // 메시지 본문과 같은 줄에 맞춘다. (아바타 + CoworkMessageItem 의 간격)
            padding: EdgeInsets.only(
              left: avatarSize + AppSpacing.s20,
              top: AppSpacing.s8,
            ),
            child: Column(
              spacing: AppSpacing.s8,
              children: [
                for (final attachment in message.attachments)
                  CoworkAttachmentCard(
                    filename: attachment.name,
                    subtitle: _sizeLabel(attachment.size),
                    icon: _iconFor(attachment),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    if (onTap == null && onLongPress == null) return item;
    return InkWell(onTap: onTap, onLongPress: onLongPress, child: item);
  }

  static IconData _iconFor(ChatAttachment attachment) =>
      switch (attachment.mimeType.split('/').first) {
        'image' => Icons.image_outlined,
        'video' => Icons.videocam_outlined,
        'audio' => Icons.audiotrack_outlined,
        _ => Icons.insert_drive_file_outlined,
      };

  /// `512 B` / `3.4 KB` / `12.0 MB`.
  static String _sizeLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
