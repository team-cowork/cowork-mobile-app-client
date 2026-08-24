import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../blocs/chat/chat_bloc.dart';
import '../widgets/channel_list.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_shortcut_bar.dart';
import '../widgets/create_sheets.dart';

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
            ChatHeader(
              label: data.workspaceName,
              onTitleTap: () => NewProjectSheet.show(context),
              onSearchTap: () => context.push('/search'),
              onNotificationTap: () => context.push('/notifications'),
            ),
            ChatShortcutBar(
              shortcuts: data.workspaceShortcuts,
              onCreateChannel: () => NewChannelSheet.show(context),
            ),
            Expanded(child: ChannelList(channelGroups: data.channelGroups)),
          ],
        ),
      ),
    );
  }
}
