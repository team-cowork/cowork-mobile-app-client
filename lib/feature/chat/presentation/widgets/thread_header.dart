import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class ThreadHeader extends StatelessWidget {
  const ThreadHeader({required this.channelName, this.onBack, super.key});

  final String channelName;
  final VoidCallback? onBack;

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
          const SizedBox(width: AppSpacing.s10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '스레드',
                style: AppFont.labelS.copyWith(color: AppColors.darkOnSurface),
              ),
              Text(
                '# $channelName',
                style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
