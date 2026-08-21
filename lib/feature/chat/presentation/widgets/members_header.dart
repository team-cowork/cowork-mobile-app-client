import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class MembersHeader extends StatelessWidget {
  const MembersHeader({
    required this.channelName,
    required this.memberCount,
    this.onBack,
    this.onInviteTap,
    super.key,
  });

  final String channelName;
  final int memberCount;
  final VoidCallback? onBack;
  final VoidCallback? onInviteTap;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '멤버',
                  style: AppFont.labelS.copyWith(color: AppColors.darkOnSurface),
                ),
                Text(
                  '# $channelName · $memberCount명',
                  style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
                ),
              ],
            ),
          ),
          GestureDetector(onTap: onInviteTap, child: AppIcon.userPlus()),
        ],
      ),
    );
  }
}
