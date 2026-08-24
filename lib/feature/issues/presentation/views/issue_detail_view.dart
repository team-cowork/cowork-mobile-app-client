import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/base_scaffold.dart';
import '../../domain/issue.dart';
import '../widgets/issue_color_mapping.dart';
import '../widgets/issue_dot_badge.dart';
import '../widgets/issue_label_chip.dart';

class IssueDetailView extends StatelessWidget {
  const IssueDetailView({required this.issue, super.key});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                    onTap: () => context.pop(),
                    child: SizedBox(
                      width: 32,
                      height: 44,
                      child: Center(child: AppIcon.chevronBack()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    '#${issue.number}',
                    style: AppFont.labelS.copyWith(
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  const Spacer(),
                  AppIcon.more(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s6,
                  AppSpacing.s16,
                  AppSpacing.s16,
                ),
                children: [
                  Wrap(
                    spacing: AppSpacing.s6,
                    runSpacing: AppSpacing.s6,
                    children: [
                      IssueDotBadge(
                        label: issue.status.label,
                        color: issue.status.tagColor,
                      ),
                      for (final label in issue.labels)
                        IssueLabelChip(label: label),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s14),
                  Text(
                    issue.title,
                    style: AppFont.titleS.copyWith(
                      height: 1.32,
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  _MetaCard(issue: issue),
                  const SizedBox(height: AppSpacing.s20),
                  Text(
                    '설명',
                    style: AppFont.subtextS.copyWith(
                      fontWeight: AppFont.semiBold,
                      color: AppColors.neutral300,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  Text(
                    issue.description,
                    style: AppFont.subtextM.copyWith(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.darkOnSurface.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s12,
                AppSpacing.s8,
                AppSpacing.s12,
                AppSpacing.s24,
              ),
              child: CoworkMessageComposer(
                hintText: '댓글 남기기',
                showAttachButton: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.issue});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      if (issue.assignee != null)
        _MetaRow(
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
        _MetaRow(label: '마감일', value: issue.dueDate!),
      if (issue.priority != null)
        _MetaRow(
          label: '우선순위',
          trailing: IssueDotBadge(
            label: issue.priority!.label,
            color: issue.priority!.tagColor,
          ),
        ),
      if (issue.milestone != null)
        _MetaRow(label: '마일스톤', value: issue.milestone!),
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, this.value, this.trailing});

  final String label;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppFont.subtextM.copyWith(color: AppColors.neutral300),
            ),
          ),
          if (trailing != null)
            trailing!
          else if (value != null)
            Text(
              value!,
              style: AppFont.labelXs.copyWith(color: AppColors.darkOnSurface),
            ),
        ],
      ),
    );
  }
}
