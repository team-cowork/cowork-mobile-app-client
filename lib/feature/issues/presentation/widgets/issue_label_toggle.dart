import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/issue_label.dart';
import 'issue_color_mapping.dart';

class IssueLabelToggle extends StatelessWidget {
  const IssueLabelToggle({
    required this.label,
    required this.selected,
    this.onTap,
    super.key,
  });

  final IssueLabel label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = label.color!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected ? color.background : AppColors.neutral750,
          border: Border.all(
            color: selected ? color.foreground : AppColors.neutral700,
          ),
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
        child: Text(
          label.name,
          style: AppFont.labelXs.copyWith(
            fontSize: 13,
            color: selected ? color.foreground : AppColors.neutral300,
          ),
        ),
      ),
    );
  }
}
