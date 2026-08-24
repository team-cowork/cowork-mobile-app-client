import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../blocs/channel/channel_bloc.dart';
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
            _ChannelHeader(
              name: data.name,
              description: data.description,
              onBack: () => context.pop(),
              onMembersTap: () => context.push('/chat/channel/members'),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s4,
                  ),
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

class _ChannelHeader extends StatelessWidget {
  const _ChannelHeader({
    required this.name,
    required this.description,
    this.onBack,
    this.onMembersTap,
    // ignore: unused_element_parameter -- 더보기 동작 미연결. 배선되면 이 줄을 지운다.
    this.onMoreTap,
  });

  final String name;
  final String description;
  final VoidCallback? onBack;
  final VoidCallback? onMembersTap;
  final VoidCallback? onMoreTap;

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
          const SizedBox(width: AppSpacing.s6),
          AppIcon.hash(),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppFont.labelS.copyWith(
                    color: AppColors.darkOnSurface,
                  ),
                ),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
                ),
              ],
            ),
          ),
          GestureDetector(onTap: onMembersTap, child: AppIcon.users()),
          const SizedBox(width: AppSpacing.s16),
          GestureDetector(onTap: onMoreTap, child: AppIcon.more()),
        ],
      ),
    );
  }
}
