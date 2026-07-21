import 'package:cowork_app/core/utils/base_scaffold.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../widgets/channel_group_header.dart';
import '../widgets/channel_group_item.dart';
import '../widgets/chat_button.dart';
import '../widgets/home_header.dart';

/// 홈(채팅 목록) 화면.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(label: '코워크'),
            _ChatShortcutBar(),
            Expanded(child: _ChannelList()),
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
        child: Row(spacing: 14, children: [ChatButton(onTap: () {})]),
      ),
    );
  }
}

/// 채널 그룹과 채널 목록.
class _ChannelList extends StatelessWidget {
  const _ChannelList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      child: SingleChildScrollView(
        child: Column(
          spacing: AppSpacing.s4,
          children: [
            const ChannelGroupHeader(label: '디자인'),
            ChannelGroupItem(icon: AppIcon.hashChannel(), label: '일반'),
            ChannelGroupItem(icon: AppIcon.webhook(), label: '웹훅'),
            ChannelGroupItem(icon: AppIcon.channelChat(), label: '잡담'),
            ChannelGroupItem(icon: AppIcon.speaker(), label: '데일리스크럼'),
          ],
        ),
      ),
    );
  }
}
