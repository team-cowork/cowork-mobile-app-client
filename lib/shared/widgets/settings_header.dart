import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 설정 화면(채널 설정·팀 설정) 맨 위의 뒤로 가기 + 제목.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({required this.title, this.onBack, super.key});

  final String title;
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
            title,
            style: AppFont.labelM.copyWith(color: AppColors.darkOnSurface),
          ),
        ],
      ),
    );
  }
}
