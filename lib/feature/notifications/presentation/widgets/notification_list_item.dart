import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/notification_item.dart';
import 'notification_leading.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({super.key, required this.item, this.onTap});

  final NotificationItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s14,
        ),
        decoration: BoxDecoration(
          color: item.isUnread
              ? AppColors.red400.withValues(alpha: 0.06)
              : null,
          borderRadius: BorderRadius.circular(AppRadius.r14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s12,
          children: [
            NotificationLeading(item: item),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    item.title,
                    style: AppFont.labelXs.copyWith(
                      fontSize: 14,
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.subtextM.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
                  Text(
                    item.time,
                    style: AppFont.subtextS.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
                ],
              ),
            ),
            if (item.isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.red400,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
