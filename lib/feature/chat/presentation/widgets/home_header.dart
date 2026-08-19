import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 홈 화면 상단 헤더. 좌측 워크스페이스 타이틀과 우측 검색/알림 아이콘으로 구성된다.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.label,
    this.onSearchTap,
    this.onNotificationTap,
    super.key,
  });

  final String label;
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
          Row(
            children: [
              Text(
                label,
                style: AppFont.titleM.copyWith(color: AppColors.neutral100),
              ),
              const SizedBox(width: AppSpacing.s6),
              AppIcon.dropDown(),
            ],
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
