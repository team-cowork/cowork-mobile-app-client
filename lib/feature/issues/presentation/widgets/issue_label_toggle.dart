import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 새 이슈 시트에서 라벨을 고르는 칩.
class IssueLabelToggle extends StatelessWidget {
  const IssueLabelToggle({
    required this.name,
    required this.selected,
    this.onTap,
    super.key,
  });

  final String name;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue900 : AppColors.neutral750,
          border: Border.all(
            color: selected ? AppColors.blue300 : AppColors.neutral700,
          ),
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
        child: Text(
          name,
          style: AppFont.labelXs.copyWith(
            fontSize: 13,
            color: selected ? AppColors.blue300 : AppColors.neutral300,
          ),
        ),
      ),
    );
  }
}
