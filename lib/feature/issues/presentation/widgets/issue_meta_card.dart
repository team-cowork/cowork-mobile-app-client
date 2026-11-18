import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/issue.dart';
import 'issue_meta_row.dart';

class IssueMetaCard extends StatelessWidget {
  const IssueMetaCard({required this.issue, super.key});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      IssueMetaRow(label: '작성자', value: issue.author),
      IssueMetaRow(label: '만든 시각', value: issue.createdAt),
    ];

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
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.neutral700,
              ),
            row,
          ],
        ],
      ),
    );
  }
}
