import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 설정 섹션 카드 안의 한 행.
///
/// 왼쪽 아이콘 + 라벨 + 선택적 [trailing] 위젯으로 구성된다.
/// [onTap]이 있으면 눌리는 행, 없으면 정적인 행이 된다.
/// [destructive]가 true면 로그아웃처럼 빨간색으로 표시한다.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.all(AppSpacing.s14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: destructive ? AppColors.red400 : AppColors.neutral300,
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              label,
              style: AppFont.subtextL.copyWith(
                color: destructive ? AppColors.red400 : AppColors.darkOnSurface,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

/// [SettingsTile]의 trailing에 쓰는 "값 + 오른쪽 화살표" 조합.
class SettingsTrailingValue extends StatelessWidget {
  const SettingsTrailingValue({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppFont.subtextM.copyWith(color: AppColors.neutral300),
        ),
        const SizedBox(width: AppSpacing.s6),
        const Icon(Icons.chevron_right, size: 18, color: AppColors.neutral300),
      ],
    );
  }
}
