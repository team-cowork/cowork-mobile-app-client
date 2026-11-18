import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../chat/data/repositories/message_repository.dart';
import '../../../team/data/repositories/team_repository.dart';
import '../../../../shared/domain/enums/chat_avatar_color.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../data/repositories/channel_repository.dart';
import '../../domain/channel_member.dart';
import '../blocs/channel_members/channel_members_bloc.dart';

class MembersView extends StatelessWidget {
  const MembersView({required this.channelId, super.key});

  final int channelId;

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<ChannelMembersBloc, ChannelMembersData>(
      create: (context) => ChannelMembersBloc(
        channelId: channelId,
        channelRepository: context.read<ChannelRepository>(),
        messageRepository: context.read<MessageRepository>(),
        teamRepository: context.read<TeamRepository>(),
      )..add(const ChannelMembersEvent.requested()),
      errorTitle: '멤버를 불러오지 못했어요',
      onRetry: (context) => context.read<ChannelMembersBloc>().add(
        const ChannelMembersEvent.requested(),
      ),
      builder: (context, data) => SafeArea(
        child: Column(
          children: [
            _MembersHeader(
              channelName: data.channelName,
              memberCount: data.members.length,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                children: [
                  for (final member in data.members)
                    _ChannelMemberTile(member: member),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MembersHeader extends StatelessWidget {
  const _MembersHeader({
    required this.channelName,
    required this.memberCount,
    this.onBack,
  });

  final String channelName;
  final int memberCount;
  final VoidCallback? onBack;

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
        ],
      ),
    );
  }
}

class _ChannelMemberTile extends StatelessWidget {
  const _ChannelMemberTile({required this.member});

  final ChannelMember member;

  /// 소유자·관리자만 배지로 보인다. 일반 멤버는 따로 보이지 않는다.
  static String? _roleLabel(ChannelMemberRole role) => switch (role) {
    ChannelMemberRole.owner => '소유자',
    ChannelMemberRole.admin => '관리자',
    ChannelMemberRole.member => null,
  };

  static Color _colorFor(ChatAvatarColor color) => switch (color) {
    ChatAvatarColor.blue => AppColors.blue500,
    ChatAvatarColor.green => AppColors.green500,
    ChatAvatarColor.amber => AppColors.amber500,
    ChatAvatarColor.red => AppColors.red400,
    ChatAvatarColor.neutral => AppColors.neutral700,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s8,
      ),
      child: Row(
        children: [
          CoworkAvatar(
            initials: member.profile.avatarInitial,
            backgroundColor: _colorFor(member.avatarColor),
            foregroundColor: AppColors.white,
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  member.profile.name,
                  style: AppFont.subtextL.copyWith(
                    color: AppColors.darkOnSurface,
                  ),
                ),
                if (member.roleNames.isNotEmpty)
                  Text(
                    member.roleNames.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.subtextS.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
              ],
            ),
          ),
          if (_roleLabel(member.role) case final label?)
            CoworkBadge(label: label),
        ],
      ),
    );
  }
}
