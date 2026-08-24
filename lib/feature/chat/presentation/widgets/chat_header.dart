import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    required this.label,
    this.onTitleTap,
    this.onSearchTap,
    this.onNotificationTap,
    super.key,
  });

  final String label;

  /// 워크스페이스 타이틀을 눌렀을 때. 없으면 정적인 타이틀이 된다.
  final VoidCallback? onTitleTap;

  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s6,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onTitleTap,
            child: Row(
              children: [
                Text(
                  label,
                  style: AppFont.titleM.copyWith(color: AppColors.neutral100),
                ),
                const SizedBox(width: AppSpacing.s6),
                AppIcon.dropDown(),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              GestureDetector(
                onTap: onSearchTap,
                child: const Icon(
                  AppIcon.search,
                  color: AppColors.neutral300,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.s18),
              GestureDetector(onTap: onNotificationTap, child: AppIcon.bell()),
            ],
          ),
        ],
      ),
    );
  }
}
