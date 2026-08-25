import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/bloc_section_scaffold.dart';
import '../../domain/channel_member.dart';
import '../../domain/enums/chat_avatar_color.dart';
import '../viewModels/group_chat_bloc.dart';

class MembersView extends StatelessWidget {
  const MembersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSectionScaffold<GroupChatBloc, GroupChatState,
        ChannelMembersData>(
      create: (_) =>
          GroupChatBloc()..add(const GroupChatEvent.membersRequested()),
      selector: (state) => state.members,
      errorTitle: '멤버를 불러오지 못했어요',
      onRetry: (context) =>
          context.read<GroupChatBloc>().add(const GroupChatEvent.membersRequested()),
      builder: (context, data) {
        final online = data.members.where((m) => m.isOnline).toList();
        final offline = data.members.where((m) => !m.isOnline).toList();

        return SafeArea(
          child: Column(
            children: [
              _MembersHeader(
                channelName: data.channelName,
                memberCount: data.members.length,
                onBack: () => context.pop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                  ),
                  children: [
                    if (online.isNotEmpty) ...[
                      _SectionLabel('온라인 — ${online.length}'),
                      for (final member in online)
                        _ChannelMemberTile(member: member),
                    ],
                    if (offline.isNotEmpty) ...[
                      _SectionLabel('오프라인 — ${offline.length}'),
                      for (final member in offline)
                        _ChannelMemberTile(member: member),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s10,
        AppSpacing.s4,
        AppSpacing.s6,
      ),
      child: Text(
        label,
        style: AppFont.labelXs.copyWith(color: AppColors.neutral300),
      ),
    );
  }
}

class _MembersHeader extends StatelessWidget {
  const _MembersHeader({
    required this.channelName,
    required this.memberCount,
    this.onBack,
    // ignore: unused_element_parameter -- 초대 동작 미연결. 배선되면 이 줄을 지운다.
    this.onInviteTap,
  });

  final String channelName;
  final int memberCount;
  final VoidCallback? onBack;
  final VoidCallback? onInviteTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s4,
        AppSpacing.s16,
        AppSpacing.s12,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '멤버',
                  style: AppFont.labelS.copyWith(
                    color: AppColors.darkOnSurface,
                  ),
                ),
                Text(
                  '# $channelName · $memberCount명',
                  style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
                ),
              ],
            ),
          ),
          GestureDetector(onTap: onInviteTap, child: AppIcon.userPlus()),
        ],
      ),
    );
  }
}

class _ChannelMemberTile extends StatelessWidget {
  const _ChannelMemberTile({
    required this.member,
    // ignore: unused_element_parameter -- 더보기 동작 미연결. 배선되면 이 줄을 지운다.
    this.onMoreTap,
  });

  final ChannelMember member;
  final VoidCallback? onMoreTap;

  static Color _colorFor(ChatAvatarColor color) => switch (color) {
    ChatAvatarColor.blue => AppColors.blue500,
    ChatAvatarColor.green => AppColors.green500,
    ChatAvatarColor.amber => AppColors.amber500,
    ChatAvatarColor.red => AppColors.red400,
    ChatAvatarColor.neutral => AppColors.neutral700,
  };

  @override
  Widget build(BuildContext context) {
    final avatar = CoworkAvatar(
      initials: member.profile.avatarInitial,
      backgroundColor: _colorFor(member.avatarColor),
      foregroundColor: AppColors.white,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSize.componentMedium,
            height: AppSize.componentMedium,
            child: Stack(
              children: [
                Opacity(opacity: member.isOnline ? 1 : 0.55, child: avatar),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: member.isOnline
                          ? AppColors.green500
                          : AppColors.neutral300,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neutral850,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.s6,
                  children: [
                    Text(
                      member.profile.name,
                      style: AppFont.subtextL.copyWith(
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    if (member.isOwner) const _OwnerBadge(),
                  ],
                ),
                Text(
                  member.role,
                  style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
                ),
              ],
            ),
          ),
          GestureDetector(onTap: onMoreTap, child: AppIcon.more(size: 20)),
        ],
      ),
    );
  }
}

/// 채널 소유자 표시. 팔레트에 없는 보라색은 이 배지 전용값이라 인라인.
class _OwnerBadge extends StatelessWidget {
  const _OwnerBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2050),
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: const Text(
        'OWNER',
        style: TextStyle(
          fontFamily: AppFont.fontFamily,
          fontFamilyFallback: AppFont.fontFamilyFallback,
          fontSize: 10,
          fontWeight: AppFont.bold,
          color: Color(0xFFD4A3FF),
        ),
      ),
    );
  }
}
