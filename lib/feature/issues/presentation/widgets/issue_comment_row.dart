import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/issue_comment.dart';
import 'issue_color_mapping.dart';

class IssueCommentRow extends StatelessWidget {
  const IssueCommentRow({required this.comment, super.key});

  final IssueComment comment;

  @override
  Widget build(BuildContext context) {
    return CoworkMessageItem(
      username: comment.author.name,
      timestamp: comment.timestamp,
      message: comment.message,
      initials: comment.author.avatarInitial,
      avatar: CoworkAvatar(
        initials: comment.author.avatarInitial,
        backgroundColor: issueAssigneeColor(comment.author.id),
        foregroundColor: AppColors.white,
      ),
    );
  }
}
