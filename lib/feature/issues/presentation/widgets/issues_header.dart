import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class IssuesHeader extends StatelessWidget {
  const IssuesHeader({
    required this.projectLabel,
    this.onSearchTap,
    super.key,
  });

  final String projectLabel;
  final VoidCallback? onSearchTap;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  '이슈',
                  style: AppFont.titleM.copyWith(color: AppColors.neutral100),
                ),
                Text(
                  projectLabel,
                  style: AppFont.subtextM.copyWith(color: AppColors.neutral300),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSearchTap,
            child: const Icon(
              AppIcon.search,
              color: AppColors.neutral300,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
