import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/issue_comment.dart';
import '../viewModels/issue_comments_cubit.dart';
import 'issue_comment_row.dart';

class IssueCommentList extends StatelessWidget {
  const IssueCommentList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IssueCommentsCubit, List<IssueComment>>(
      builder: (context, comments) {
        if (comments.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '댓글 ${comments.length}',
              style: AppFont.subtextS.copyWith(
                fontWeight: AppFont.semiBold,
                color: AppColors.neutral300,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            for (final (index, comment) in comments.indexed) ...[
              if (index > 0) const SizedBox(height: AppSpacing.s16),
              IssueCommentRow(comment: comment),
            ],
          ],
        );
      },
    );
  }
}
