import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../../notifications/presentation/views/notifications_view.dart';
import '../../../search/presentation/views/search_view.dart';
import '../viewModels/chat_bloc.dart';
import '../widgets/channel_list.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_shortcut_bar.dart';

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
              onSearchTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SearchView()),
              ),
              onNotificationTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const NotificationsView()),
              ),
            ),
            const ChatShortcutBar(),
            Expanded(child: ChannelList(channelGroups: data.channelGroups)),
          ],
        ),
      ),
    );
  }
}
