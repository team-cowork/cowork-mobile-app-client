import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 홈 화면 상단 헤더. 좌측 워크스페이스 타이틀과 우측 검색/알림 아이콘으로 구성된다.
class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.label, this.onTitleTap, super.key});

  final String label;

  /// 워크스페이스 타이틀을 눌렀을 때. 없으면 정적인 타이틀이 된다.
  final VoidCallback? onTitleTap;

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
              const Icon(AppIcon.search, color: AppColors.neutral300, size: 22),
              const SizedBox(width: AppSpacing.s18),
              AppIcon.bell(),
            ],
          ),
        ],
      ),
    );
  }
}
