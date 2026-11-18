import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/issue_comment.dart';
import 'issue_color_mapping.dart';

class IssueCommentRow extends StatelessWidget {
  const IssueCommentRow({required this.comment, super.key});

  final IssueComment comment;

  @override
  Widget build(BuildContext context) {
    final initial = comment.author.isEmpty
        ? '?'
        : String.fromCharCode(comment.author.runes.first).toUpperCase();
    return CoworkMessageItem(
      username: comment.author,
      timestamp: comment.timestamp,
      message: comment.message,
      initials: initial,
      avatar: CoworkAvatar(
        initials: initial,
        backgroundColor: issueAuthorColor(comment.author),
        foregroundColor: AppColors.white,
      ),
    );
  }
}
