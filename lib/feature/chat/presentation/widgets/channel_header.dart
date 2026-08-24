import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class ChannelHeader extends StatelessWidget {
  const ChannelHeader({
    required this.name,
    required this.description,
    this.onBack,
    this.onMembersTap,
    this.onMoreTap,
    super.key,
  });

  final String name;
  final String description;
  final VoidCallback? onBack;
  final VoidCallback? onMembersTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: SizedBox(
              width: 32,
              height: 44,
              child: Center(child: AppIcon.chevronBack()),
            ),
          ),
          const SizedBox(width: AppSpacing.s6),
          AppIcon.hash(),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppFont.labelS.copyWith(
                    color: AppColors.darkOnSurface,
                  ),
                ),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
                ),
              ],
            ),
          ),
          GestureDetector(onTap: onMembersTap, child: AppIcon.users()),
          const SizedBox(width: AppSpacing.s16),
          GestureDetector(onTap: onMoreTap, child: AppIcon.more()),
        ],
      ),
    );
  }
}
