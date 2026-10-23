import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/bloc_scaffold.dart';
import '../../../../network/chat_socket.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../data/repositories/channel_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../blocs/channel_message/channel_message_bloc.dart';
import '../widgets/chat_message_row.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({required this.channelId, super.key});

  final int channelId;

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<ChannelMessageBloc, ChannelConversation>(
      create: (context) => ChannelMessageBloc(
        channelId: channelId,
        channelRepository: context.read<ChannelRepository>(),
        messageRepository: context.read<MessageRepository>(),
        profileRepository: context.read<ProfileRepository>(),
        socket: context.read<ChatSocket>(),
      )..add(const ChannelMessageEvent.requested()),
      errorTitle: '채널을 불러오지 못했어요',
      onRetry: (context) => context.read<ChannelMessageBloc>().add(
        const ChannelMessageEvent.requested(),
      ),
      builder: (context, data) =>
          BlocListener<ChannelMessageBloc, ChannelMessageState>(
            listenWhen: (previous, current) =>
                current is AsyncSuccess<ChannelConversation> &&
                current.data.errorMessage != null,
            listener: (context, state) {
              final message = (state as AsyncSuccess<ChannelConversation>)
                  .data
                  .errorMessage!;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            },
            child: SafeArea(
              child: Column(
                children: [
                  _ChannelHeader(
                    name: data.name,
                    description: data.description,
                    onBack: () => context.pop(),
                    onMembersTap: () => context.push('/chat/channel/members'),
                    onMoreTap: () => context.push('/chat/channel/settings'),
                  ),
                  Expanded(child: _MessageList(data: data)),
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
          ),
    );
  }
}

/// 최신 메시지가 아래에 붙는 대화 목록. 위 끝 근처까지 올리면 이전 메시지를 부른다.
class _MessageList extends StatelessWidget {
  const _MessageList({required this.data});

  final ChannelConversation data;

  /// 위 끝에서 이만큼 남으면 미리 이전 메시지를 부른다.
  static const _loadOlderExtent = 400.0;

  @override
  Widget build(BuildContext context) {
    final messages = data.messages;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (data.hasOlder &&
            !data.loadingOlder &&
            notification.metrics.extentAfter < _loadOlderExtent) {
          context.read<ChannelMessageBloc>().add(
            const ChannelMessageEvent.olderRequested(),
          );
        }
        return false;
      },
      child: ListView.separated(
        reverse: true,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s16,
        ),
        itemCount: messages.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s18),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
          child: ChatMessageRow(
            message: messages[messages.length - 1 - index],
            onTap: () => context.push('/chat/channel/thread'),
          ),
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
