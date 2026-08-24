import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class NotificationsHeader extends StatelessWidget {
  const NotificationsHeader({super.key, this.onBack, this.onMarkAllRead});

  final VoidCallback? onBack;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s4,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      child: Row(
        spacing: AppSpacing.s8,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const SizedBox(
              width: 32,
              height: 44,
              child: Icon(
                AppIcon.back,
                size: 24,
                color: AppColors.darkOnSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '알림',
              style: AppFont.titleS.copyWith(color: AppColors.darkOnSurface),
            ),
          ),
          GestureDetector(
            onTap: onMarkAllRead,
            child: Text(
              '모두 읽음',
              style: AppFont.labelXs.copyWith(color: AppColors.red400),
            ),
          ),
        ],
      ),
    );
  }
}
