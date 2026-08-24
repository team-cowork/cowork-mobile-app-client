import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/issue_tag_color.dart';
import 'issue_color_mapping.dart';

/// 상태/우선순위 배지. 스타디움 모양 + 앞의 점.
class IssueDotBadge extends StatelessWidget {
  const IssueDotBadge({required this.label, required this.color, super.key});

  final String label;
  final IssueTagColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 3),
      decoration: BoxDecoration(
        color: color.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color.foreground,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            label,
            style: AppFont.labelXs.copyWith(fontSize: 11, color: color.foreground),
          ),
        ],
      ),
    );
  }
}
