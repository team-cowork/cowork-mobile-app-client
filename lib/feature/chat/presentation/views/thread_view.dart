import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/chat_socket.dart';
import '../../../../core/utils/async_state.dart';
import '../../../../shared/utils/external_url.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../channel/data/repositories/channel_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../domain/chat_message.dart';
import '../blocs/thread/thread_bloc.dart';
import '../utils/attachment_opener.dart';
import '../widgets/chat_message_row.dart';

class ThreadView extends StatefulWidget {
  const ThreadView({
    required this.channelId,
    required this.parentMessageId,
    this.openUrl = launchExternally,
    super.key,
  });

  final int channelId;

  /// 스레드의 부모(맨 위) 메시지 id.
  final String parentMessageId;

  /// 첨부파일 주소를 여는 방법. 테스트에서 바꾼다.
  final UrlOpener openUrl;

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  late final _attachmentOpener = AttachmentOpener(
    repository: context.read<MessageRepository>(),
    open: widget.openUrl,
  );

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAttachment(ChatMessage message, int index) async {
    final failure = await _attachmentOpener.open(
      widget.channelId,
      message.id,
      index,
    );
    if (failure != null && mounted) _notify(failure);
  }

  @override
  Widget build(BuildContext context) {
    final channelId = widget.channelId;
    final parentMessageId = widget.parentMessageId;
    return BlocScaffold<ThreadBloc, ThreadConversation>(
      create: (context) => ThreadBloc(
        channelId: channelId,
        parentMessageId: parentMessageId,
        channelRepository: context.read<ChannelRepository>(),
        messageRepository: context.read<MessageRepository>(),
        socket: context.read<ChatSocket>(),
      )..add(const ThreadEvent.requested()),
      errorTitle: '스레드를 불러오지 못했어요',
      onRetry: (context) =>
          context.read<ThreadBloc>().add(const ThreadEvent.requested()),
      builder: (context, conversation) => BlocListener<ThreadBloc, ThreadState>(
        listenWhen: (previous, current) =>
            current is AsyncSuccess<ThreadConversation> &&
            current.data.errorMessage != null,
        listener: (context, state) {
          _notify(
            (state as AsyncSuccess<ThreadConversation>).data.errorMessage!,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              _ThreadHeader(
                channelName: conversation.thread.channelName,
                onBack: () => context.pop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                      ),
                      child: ChatMessageRow(
                        message: conversation.thread.rootMessage,
                        onAttachmentTap: (index) => _openAttachment(
                          conversation.thread.rootMessage,
                          index,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s16,
                        AppSpacing.s16,
                        AppSpacing.s16,
                        AppSpacing.s12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '답글 ${conversation.thread.replies.length}개',
                            style: AppFont.labelXs.copyWith(
                              color: AppColors.neutral300,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: context.colors.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                      ),
                      child: Column(
                        spacing: AppSpacing.s18,
                        children: [
                          for (final reply in conversation.thread.replies)
                            ChatMessageRow(
                              message: reply,
                              avatarSize: 32,
                              onAttachmentTap: (index) =>
                                  _openAttachment(reply, index),
                            ),
                        ],
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
                child: _ReplyComposer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 답글 입력창. 보내면 비운다.
class _ReplyComposer extends StatefulWidget {
  const _ReplyComposer();

  @override
  State<_ReplyComposer> createState() => _ReplyComposerState();
}

class _ReplyComposerState extends State<_ReplyComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<ThreadBloc>().add(ThreadEvent.replySent(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CoworkMessageComposer(
      hintText: '스레드에 답글 남기기',
      showAttachButton: false,
      controller: _controller,
      onSubmitted: (_) => _send(),
      onSend: _send,
    );
  }
}

class _ThreadHeader extends StatelessWidget {
  const _ThreadHeader({required this.channelName, this.onBack});

  final String channelName;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: SizedBox(
              width: 32,
              height: 44,
              child: Center(child: AppIcon.chevronBack()),
            ),
          ),
          const SizedBox(width: AppSpacing.s10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '스레드',
                style: AppFont.labelS.copyWith(color: AppColors.darkOnSurface),
              ),
              Text(
                '# $channelName',
                style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
