import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/issue_comments/issue_comments_cubit.dart';

class IssueCommentComposer extends StatefulWidget {
  const IssueCommentComposer({super.key});

  @override
  State<IssueCommentComposer> createState() => _IssueCommentComposerState();
}

class _IssueCommentComposerState extends State<IssueCommentComposer> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 서버가 접수했을 때만 입력창을 비운다. 못 보냈으면 쓴 내용을 두어 다시 보낼 수 있다.
  Future<void> _send() async {
    final text = _controller.text;
    if (_sending || text.trim().isEmpty) return;
    final cubit = context.read<IssueCommentsCubit>();
    _sending = true;
    final sent = await cubit.send(text);
    _sending = false;
    if (sent && mounted && _controller.text == text) _controller.clear();
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
