import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/chat_avatar_color_mapping.dart';
import '../../domain/direct_message_preview.dart';

class DmListTile extends StatelessWidget {
  const DmListTile({
    required this.preview,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final DirectMessagePreview preview;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final hasUnread = preview.unreadCount > 0;
    final messageColor = hasUnread
        ? AppColors.darkOnSurface
        : AppColors.neutral300;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.r12),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s10,
          children: [
            CoworkAvatar(
              initials: preview.profile.avatarInitial,
              size: 40,
              backgroundColor: preview.avatarColor.toColor(),
              foregroundColor: AppColors.white,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    preview.profile.name,
                    style: AppFont.subtextL.copyWith(
                      fontWeight: AppFont.semiBold,
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  Text(
                    preview.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.subtextM.copyWith(color: messageColor),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 5,
              children: [
                Text(
                  preview.timestamp,
                  style: AppFont.subtextS.copyWith(
                    fontSize: 11,
                    color: hasUnread ? AppColors.red400 : AppColors.neutral300,
                  ),
                ),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s6,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.red400,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${preview.unreadCount}',
                      style: const TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontFamilyFallback: AppFont.fontFamilyFallback,
                        fontSize: 11,
                        fontWeight: AppFont.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
