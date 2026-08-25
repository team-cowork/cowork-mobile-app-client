import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../viewModels/issue_comments_cubit.dart';

class IssueCommentComposer extends StatefulWidget {
  const IssueCommentComposer({super.key});

  @override
  State<IssueCommentComposer> createState() => _IssueCommentComposerState();
}

class _IssueCommentComposerState extends State<IssueCommentComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    context.read<IssueCommentsCubit>().addComment(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s8,
        AppSpacing.s12,
        AppSpacing.s24,
      ),
      child: CoworkMessageComposer(
        controller: _controller,
        hintText: '댓글 남기기',
        showAttachButton: false,
        onSend: _send,
        onSubmitted: (_) => _send(),
      ),
    );
  }
}
