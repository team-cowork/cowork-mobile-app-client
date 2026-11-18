import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/issue_comments/issue_comments_cubit.dart';
import 'issue_comment_row.dart';

class IssueCommentList extends StatelessWidget {
  const IssueCommentList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IssueCommentsCubit, IssueCommentsState>(
      listenWhen: (previous, current) =>
          current.error != null && current.error != previous.error,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.error!))),
      builder: (context, state) {
        if (state.loading && state.comments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.s16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (state.comments.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '댓글 ${state.comments.length}',
              style: AppFont.subtextS.copyWith(
                fontWeight: AppFont.semiBold,
                color: AppColors.neutral300,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            for (final (index, comment) in state.comments.indexed) ...[
              if (index > 0) const SizedBox(height: AppSpacing.s16),
              IssueCommentRow(comment: comment),
            ],
          ],
        );
      },
    );
  }
}
