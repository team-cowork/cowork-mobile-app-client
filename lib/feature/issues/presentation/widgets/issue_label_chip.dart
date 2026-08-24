import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/issue_label.dart';
import 'issue_color_mapping.dart';

/// 이슈 라벨 배지. 색상이 있으면 색이 있는 사각 배지, 없으면 중립 [CoworkBadge].
class IssueLabelChip extends StatelessWidget {
  const IssueLabelChip({required this.label, super.key});

  final IssueLabel label;

  @override
  Widget build(BuildContext context) {
    final color = label.color;
    if (color == null) return CoworkBadge(label: label.name);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.background,
        borderRadius: BorderRadius.circular(AppRadius.r6),
      ),
      child: Text(
        label.name,
        style: AppFont.labelXs.copyWith(fontSize: 11, color: color.foreground),
      ),
    );
  }
}
