import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/profile.dart';

/// GitHub 커밋 스트릭 카드.
class GithubStreakCard extends StatelessWidget {
  const GithubStreakCard({super.key, required this.streak});

  final GithubStreak streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        18,
        AppSpacing.s20,
        AppSpacing.s20,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        border: Border.all(color: AppColors.neutral700),
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GitHub 커밋 스트릭',
                style: AppFont.labelS.copyWith(color: AppColors.darkOnSurface),
              ),
              Text(
                streak.rangeLabel,
                style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          // TODO: 실제 커밋 데이터로 히트맵 렌더링하는 로직 추가
          Container(
            height: 115,
            decoration: BoxDecoration(
              color: AppColors.neutral850,
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            alignment: Alignment.center,
            child: Text(
              '커밋 히트맵',
              style: AppFont.subtextS.copyWith(color: AppColors.neutral400),
            ),
          ),
        ],
      ),
    );
  }
}
