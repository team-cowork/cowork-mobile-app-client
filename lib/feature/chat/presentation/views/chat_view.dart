import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../domain/channel.dart';
import '../blocs/chat/chat_bloc.dart';
import '../widgets/channel_group_header.dart';
import '../widgets/channel_group_item.dart';
import '../widgets/chat_button.dart';
import '../widgets/create_sheets.dart';
import '../widgets/home_header.dart';

/// 홈(채팅 목록) 화면.
class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<ChatBloc, ChatHomeData>(
      create: (_) => ChatBloc()..add(const ChatRequested()),
      errorTitle: '채널 목록을 불러오지 못했어요',
      onRetry: (context) => context.read<ChatBloc>().add(const ChatRequested()),
      builder: (context, data) => SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(
              label: data.workspaceName,
              onTitleTap: () => NewProjectSheet.show(context),
            ),
            const _ChatShortcutBar(),
            Expanded(child: _ChannelList(channelGroups: data.channelGroups)),
          ],
        ),
      ),
    );
  }
}

/// 상단의 가로 스크롤 채팅 바로가기 목록.
class _ChatShortcutBar extends StatelessWidget {
  const _ChatShortcutBar();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s4,
          AppSpacing.s16,
          AppSpacing.s14,
        ),
        child: Row(
          spacing: 14,
          children: [
            CoworkIconButton.custom(
              icon: AppIcon.plus(),
              semanticLabel: '새 채널',
              onPressed: () => NewChannelSheet.show(context),
            ),
            ChatButton(onTap: () {}),
          ],
        ),
      ),
    );
  }
}

/// 채널 그룹과 채널 목록.
class _ChannelList extends StatelessWidget {
  const _ChannelList({required this.channelGroups});

  final List<ChannelGroup> channelGroups;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      child: SingleChildScrollView(
        child: Column(
          spacing: AppSpacing.s4,
          children: [
            for (final group in channelGroups) ...[
              ChannelGroupHeader(label: group.name),
              for (final channel in group.channels)
                ChannelGroupItem.type(type: channel.type, label: channel.name),
            ],
          ],
        ),
      ),
    );
  }
}
