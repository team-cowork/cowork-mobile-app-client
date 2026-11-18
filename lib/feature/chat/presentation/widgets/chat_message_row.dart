import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/chat_avatar_color_mapping.dart';
import '../../domain/chat_attachment.dart';
import '../../domain/chat_message.dart';

/// [attachment] 이미지를 그릴 위젯. [index] 는 메시지 안에서 몇 번째 첨부인지.
typedef AttachmentImageBuilder =
    Widget Function(int index, ChatAttachment attachment);

class ChatMessageRow extends StatelessWidget {
  const ChatMessageRow({
    required this.message,
    this.avatarSize = AppSize.componentMedium,
    this.onTap,
    this.onLongPress,
    this.onAttachmentTap,
    this.imageBuilder,
    super.key,
  });

  final ChatMessage message;
  final double avatarSize;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 첨부파일 카드를 눌렀다. 몇 번째 첨부인지 넘긴다.
  final ValueChanged<int>? onAttachmentTap;

  /// 주면 대화 안에서 볼 수 있는 이미지 첨부([ChatAttachment.isPreviewableImage])를
  /// 카드 대신 이 위젯으로 그린다.
  final AttachmentImageBuilder? imageBuilder;

  @override
  Widget build(BuildContext context) {
    final Widget item = CoworkMessageItem(
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
      // 본문 칸 안에 그려야 파일만 있는 메시지도 머리줄 바로 아래에 붙는다.
      footer: message.attachments.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s8,
              children: [
                for (final (index, attachment) in message.attachments.indexed)
                  if (imageBuilder != null && attachment.isPreviewableImage)
                    imageBuilder!(index, attachment)
                  else
                    CoworkAttachmentCard(
                      filename: attachment.name,
                      subtitle: _sizeLabel(attachment.size),
                      icon: _iconFor(attachment),
                      onTap: onAttachmentTap == null
                          ? null
                          : () => onAttachmentTap!(index),
                    ),
              ],
            ),
    );

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
