import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../viewModels/channel_bloc.dart';
import '../widgets/channel_header.dart';
import '../widgets/chat_message_row.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<ChannelBloc, ChannelConversationData>(
      create: (_) => ChannelBloc()..add(const ChannelRequested()),
      errorTitle: '채널을 불러오지 못했어요',
      onRetry: (context) =>
          context.read<ChannelBloc>().add(const ChannelRequested()),
      builder: (context, data) => SafeArea(
        child: Column(
          children: [
            ChannelHeader(
              name: data.name,
              description: data.description,
              onBack: () => context.pop(),
              onMembersTap: () => context.push('/chat/channel/members'),
              onMoreTap: () => context.push('/chat/channel/settings'),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12,
                  vertical: AppSpacing.s16,
                ),
                itemCount: data.messages.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.s18),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                  child: ChatMessageRow(
                    message: data.messages[index],
                    onTap: () => context.push('/chat/channel/thread'),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s12,
                AppSpacing.s8,
                AppSpacing.s12,
                AppSpacing.s24,
              ),
              child: CoworkMessageComposer(hintText: '메시지를 입력하세요'),
            ),
          ],
        ),
      ),
    );
  }
}
