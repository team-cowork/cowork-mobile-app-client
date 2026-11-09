import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/chat_socket.dart';
import '../../../../core/utils/async_state.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../channel/data/repositories/channel_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../domain/message_thread.dart';
import '../blocs/thread/thread_bloc.dart';
import '../widgets/chat_message_row.dart';

class ThreadView extends StatelessWidget {
  const ThreadView({
    required this.channelId,
    required this.parentMessageId,
    super.key,
  });

  final int channelId;

  /// 스레드의 부모(맨 위) 메시지 id.
  final String parentMessageId;

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<ThreadBloc, MessageThread>(
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
      builder: (context, thread) => BlocListener<ThreadBloc, ThreadState>(
        listenWhen: (previous, current) =>
            current is AsyncSuccess<MessageThread> &&
            current.data.errorMessage != null,
        listener: (context, state) {
          final message = (state as AsyncSuccess<MessageThread>)
              .data
              .errorMessage!;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        child: SafeArea(
          child: Column(
            children: [
              _ThreadHeader(
                channelName: thread.channelName,
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
                      child: ChatMessageRow(message: thread.rootMessage),
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
                            '답글 ${thread.replies.length}개',
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
                          for (final reply in thread.replies)
                            ChatMessageRow(message: reply, avatarSize: 32),
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
