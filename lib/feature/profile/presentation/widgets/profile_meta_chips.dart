import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 학년/GitHub/DataGSM 연동 등 프로필 메타 정보 칩 목록.
class ProfileMetaChips extends StatelessWidget {
  const ProfileMetaChips({super.key, required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s8,
      children: [
        for (final label in labels)
          Container(
            decoration: BoxDecoration(
              color: AppColors.neutral750,
              border: Border.all(color: AppColors.neutral700),
              borderRadius: BorderRadius.circular(AppRadius.r14),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s6,
            ),
            child: Text(
              label,
              style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
            ),
          ),
      ],
    );
  }
}
