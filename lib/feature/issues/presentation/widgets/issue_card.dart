import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/issue.dart';
import 'issue_color_mapping.dart';
import 'issue_label_chip.dart';

class IssueCard extends StatelessWidget {
  const IssueCard({required this.issue, this.onTap, super.key});

  final Issue issue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final assignee = issue.assignee;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s14,
          vertical: AppSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral800,
          border: Border.all(color: AppColors.neutral700),
          borderRadius: BorderRadius.circular(AppRadius.r12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s10,
          children: [
            if (issue.labels.isNotEmpty)
              Wrap(
                spacing: AppSpacing.s6,
                runSpacing: AppSpacing.s6,
                children: [
                  for (final label in issue.labels) IssueLabelChip(label: label),
                ],
              ),
            Text(
              issue.title,
              style: AppFont.subtextL.copyWith(
                fontWeight: AppFont.semiBold,
                height: 1.35,
                color: AppColors.neutral100,
              ),
            ),
            Row(
              spacing: AppSpacing.s8,
              children: [
                Text(
                  '#${issue.number}',
                  style: AppFont.labelXs.copyWith(color: AppColors.neutral300),
                ),
                if (issue.dueDate != null)
                  Text(
                    '📅 ${issue.dueDate}',
                    style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
                  ),
                const Expanded(child: SizedBox()),
                if (assignee != null)
                  CoworkAvatar(
                    initials: assignee.avatarInitial,
                    size: 22,
                    backgroundColor: issueAssigneeColor(assignee.id),
                    foregroundColor: AppColors.white,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
