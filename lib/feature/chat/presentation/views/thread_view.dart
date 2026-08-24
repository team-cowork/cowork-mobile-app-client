import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/bloc_section_scaffold.dart';
import '../../domain/message_thread.dart';
import '../viewModels/group_chat_bloc.dart';
import '../widgets/chat_message_row.dart';
import '../widgets/thread_header.dart';

class ThreadView extends StatelessWidget {
  const ThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSectionScaffold<GroupChatBloc, GroupChatState, MessageThread>(
      create: (_) =>
          GroupChatBloc()..add(const GroupChatEvent.threadRequested()),
      selector: (state) => state.thread,
      errorTitle: '스레드를 불러오지 못했어요',
      onRetry: (context) =>
          context.read<GroupChatBloc>().add(const GroupChatEvent.threadRequested()),
      builder: (context, thread) => SafeArea(
        child: Column(
          children: [
            ThreadHeader(
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
              child: CoworkMessageComposer(
                hintText: '스레드에 답글 남기기',
                showAttachButton: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
