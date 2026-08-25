import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/base_scaffold.dart';
import '../../domain/issue.dart';
import 'issue_color_mapping.dart';
import 'issue_comment_composer.dart';
import 'issue_comment_list.dart';
import 'issue_dot_badge.dart';
import 'issue_label_chip.dart';
import 'issue_meta_card.dart';

class IssueDetailBody extends StatelessWidget {
  const IssueDetailBody({required this.issue, super.key});

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
                  IssueMetaCard(issue: issue),
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
                  const SizedBox(height: AppSpacing.s20),
                  const IssueCommentList(),
                ],
              ),
            ),
            const IssueCommentComposer(),
          ],
        ),
      ),
    );
  }
}
