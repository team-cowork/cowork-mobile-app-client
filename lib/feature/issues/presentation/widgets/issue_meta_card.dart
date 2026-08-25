import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/issue.dart';
import 'issue_color_mapping.dart';
import 'issue_dot_badge.dart';
import 'issue_meta_row.dart';

class IssueMetaCard extends StatelessWidget {
  const IssueMetaCard({required this.issue, super.key});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      if (issue.assignee != null)
        IssueMetaRow(
          label: '담당자',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.s6,
            children: [
              CoworkAvatar(
                initials: issue.assignee!.avatarInitial,
                size: 22,
                backgroundColor: issueAssigneeColor(issue.assignee!.id),
                foregroundColor: AppColors.white,
              ),
              Text(
                issue.assignee!.name,
                style: AppFont.labelXs.copyWith(color: AppColors.darkOnSurface),
              ),
            ],
          ),
        ),
      if (issue.dueDate != null)
        IssueMetaRow(label: '마감일', value: issue.dueDate!),
      if (issue.priority != null)
        IssueMetaRow(
          label: '우선순위',
          trailing: IssueDotBadge(
            label: issue.priority!.label,
            color: issue.priority!.tagColor,
          ),
        ),
      if (issue.milestone != null)
        IssueMetaRow(label: '마일스톤', value: issue.milestone!),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        border: Border.all(color: AppColors.neutral700),
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Column(
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0)
              const Divider(height: 1, thickness: 1, color: AppColors.neutral700),
            row,
          ],
        ],
      ),
    );
  }
}
