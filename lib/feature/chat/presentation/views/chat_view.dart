import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../domain/channel.dart';
import '../../domain/enums/channel_type.dart';
import '../blocs/chat/chat_bloc.dart';
import '../widgets/create_sheets.dart';

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
            _HomeHeader(
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
            _ChatButton(onTap: () {}),
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
              _ChannelGroupHeader(label: group.name),
              for (final channel in group.channels)
                _ChannelGroupItem(type: channel.type, label: channel.name),
            ],
          ],
        ),
      ),
    );
  }
}

/// 홈 화면 상단 헤더. 좌측 워크스페이스 타이틀과 우측 검색/알림 아이콘으로 구성된다.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.label, this.onTitleTap});

  final String label;

  /// 워크스페이스 타이틀을 눌렀을 때. 없으면 정적인 타이틀이 된다.
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s6,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onTitleTap,
            child: Row(
              children: [
                Text(
                  label,
                  style: AppFont.titleM.copyWith(color: AppColors.neutral100),
                ),
                const SizedBox(width: AppSpacing.s6),
                AppIcon.dropDown(),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(AppIcon.search, color: AppColors.neutral300, size: 22),
              const SizedBox(width: AppSpacing.s18),
              AppIcon.bell(),
            ],
          ),
        ],
      ),
    );
  }
}

/// 홈 화면 상단의 정사각형 채널 리스트 버튼.
class _ChatButton extends StatelessWidget {
  const _ChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSize.componentLarge,
        height: AppSize.componentLarge,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.neutral750,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// 채널 목록의 그룹(카테고리) 헤더. 펼침/접힘 화살표와 그룹명을 표시한다.
class _ChannelGroupHeader extends StatelessWidget {
  const _ChannelGroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s12,
        0,
        AppSpacing.s4,
      ),
      child: Row(
        children: [
          AppIcon.dropDown(size: 12),
          const SizedBox(width: AppSpacing.s4),
          Text(
            label,
            style: AppFont.itemCount.copyWith(color: AppColors.neutral300),
          ),
        ],
      ),
    );
  }
}

/// 채널 그룹 안의 개별 항목(아이콘 + 이름).
class _ChannelGroupItem extends StatelessWidget {
  const _ChannelGroupItem({required this.type, required this.label});

  final ChannelType type;
  final String label;

  static Widget _iconFor(ChannelType type) => switch (type) {
    ChannelType.chat => AppIcon.channelChat(),
    ChannelType.webhook => AppIcon.webhook(),
    ChannelType.file => const Icon(
      Icons.insert_drive_file_outlined,
      size: AppSize.iconSmall,
      color: AppColors.neutral300,
    ),
    ChannelType.accountShare => const Icon(
      Icons.key,
      size: AppSize.iconSmall,
      color: AppColors.neutral300,
    ),
    ChannelType.meetingNote => const Icon(
      AppIcon.navNote,
      size: AppSize.iconSmall,
      color: AppColors.neutral300,
    ),
    ChannelType.voice => AppIcon.speaker(),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: AppSpacing.s12,
      ),
      child: Row(
        children: [
          _iconFor(type),
          const SizedBox(width: AppSpacing.s10),
          Text(
            label,
            style: AppFont.subtextL.copyWith(color: AppColors.neutral300),
          ),
        ],
      ),
    );
  }
}
