import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class ChannelSettingsHeader extends StatelessWidget {
  const ChannelSettingsHeader({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s4,
        AppSpacing.s16,
        AppSpacing.s10,
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
          const SizedBox(width: AppSpacing.s8),
          Text(
            '채널 설정',
            style: AppFont.labelM.copyWith(color: AppColors.darkOnSurface),
          ),
        ],
      ),
    );
  }
}
