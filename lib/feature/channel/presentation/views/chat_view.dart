import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../../../network/chat_socket.dart';
import '../../../team/data/repositories/team_repository.dart';
import '../../../team/presentation/widgets/new_team_sheet.dart';
import '../../../team/presentation/widgets/team_menu_sheet.dart';
import '../../data/repositories/channel_repository.dart';
import '../../domain/channel.dart';
import '../../domain/enums/channel_type.dart';
import '../../domain/enums/workspace_avatar_color.dart';
import '../../domain/workspace_shortcut.dart';
import '../blocs/channel_list/channel_list_bloc.dart';
import '../widgets/create_sheets.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<ChannelListBloc, ChannelListData>(
      create: (context) => ChannelListBloc(
        context.read<TeamRepository>(),
        context.read<ChannelRepository>(),
        context.read<ChatSocket>(),
      )..add(const ChannelListRequested()),
      // 어느 단계(팀/채널)가 실패했는지는 설명 문구에 실려 온다. (#94)
      errorTitle: '홈을 불러오지 못했어요',
      onRetry: (context) =>
          context.read<ChannelListBloc>().add(const ChannelListRequested()),
      builder: (context, data) => switch (data.teamId) {
        // 팀이 없어도 단축 바는 둔다. 팀 생성 진입점을 `+` 하나로 맞추려는 것이다.
        null => SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChatShortcutBar(
                shortcuts: const [],
                onDmHomeTap: () => context.push('/dm'),
                onCreateTeam: () => _createTeam(context),
              ),
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s16),
                    child: CoworkEmptyState(
                      icon: Icons.groups_outlined,
                      title: '아직 속한 팀이 없어요',
                      description: '+ 로 팀을 만들거나 초대받으면 채널이 여기에 보여요.',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        final teamId => SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChatHeader(
                label: data.workspaceName,
                onTitleTap: () => TeamMenuSheet.show(
                  context,
                  teamName: data.workspaceName,
                  onCreateChannel: () => _createChannel(context, teamId),
                  onCreateProject: () => NewProjectSheet.show(context),
                ),
                onSearchTap: () => context.push('/search'),
                onNotificationTap: () => context.push('/notifications'),
              ),
              _ChatShortcutBar(
                shortcuts: data.workspaceShortcuts,
                onDmHomeTap: () => context.push('/dm'),
                onTeamTap: (id) => context.read<ChannelListBloc>().add(
                  ChannelListEvent.teamSelected(id),
                ),
                onCreateTeam: () => _createTeam(context),
              ),
              Expanded(child: _ChannelList(channelGroups: data.channelGroups)),
            ],
          ),
        ),
      },
    );
  }

  /// 팀 생성 시트를 띄우고, 만들어지면 그 팀으로 옮기고 알린다.
  static Future<void> _createTeam(BuildContext context) async {
    final bloc = context.read<ChannelListBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final team = await NewTeamSheet.show(context);
    if (team == null) return;
    bloc.add(ChannelListEvent.teamCreated(team));
    messenger.showSnackBar(SnackBar(content: Text('${team.name} 팀을 만들었어요.')));
  }

  /// 채널 생성 시트를 띄우고, 만들어지면 목록 끝에 붙이고 알린다.
  static Future<void> _createChannel(BuildContext context, int teamId) async {
    final bloc = context.read<ChannelListBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final channel = await NewChannelSheet.show(context, teamId: teamId);
    if (channel == null) return;
    bloc.add(ChannelListEvent.channelAdded(channel));
    messenger.showSnackBar(
      SnackBar(content: Text('#${channel.name} 채널을 만들었어요.')),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.label,
    this.onTitleTap,
    this.onSearchTap,
    this.onNotificationTap,
  });

  final String label;

  /// 워크스페이스 타이틀을 눌렀을 때. 없으면 정적인 타이틀이 된다.
  final VoidCallback? onTitleTap;

  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

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
              GestureDetector(
                onTap: onSearchTap,
                child: AppIcon.search(size: 22),
              ),
              const SizedBox(width: AppSpacing.s18),
              GestureDetector(onTap: onNotificationTap, child: AppIcon.bell()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatShortcutBar extends StatelessWidget {
  const _ChatShortcutBar({
    required this.shortcuts,
    this.onDmHomeTap,
    this.onTeamTap,
    this.onCreateTeam,
  });

  final List<WorkspaceShortcut> shortcuts;

  /// DM 홈 버튼을 눌렀을 때.
  final VoidCallback? onDmHomeTap;

  /// 팀 아바타를 눌렀을 때. 누른 팀 id 를 넘긴다.
  final ValueChanged<int>? onTeamTap;

  /// 팀 목록 끝 `+` 를 눌렀을 때. 웹 팀 레일의 `팀 추가` 와 같은 자리다.
  final VoidCallback? onCreateTeam;

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
            GestureDetector(
              onTap: onDmHomeTap,
              child: Container(
                width: AppSize.componentLarge,
                height: AppSize.componentLarge,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.neutral750,
                  shape: BoxShape.circle,
                ),
                child: AppIcon.dmHome(),
              ),
            ),
            for (final shortcut in shortcuts)
              _WorkspaceShortcutButton(
                shortcut: shortcut,
                onTap: () => onTeamTap?.call(shortcut.id),
              ),
            CoworkIconButton.custom(
              icon: AppIcon.plus(),
              semanticLabel: '새 팀',
              onPressed: onCreateTeam,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceShortcutButton extends StatelessWidget {
  const _WorkspaceShortcutButton({required this.shortcut, this.onTap});

  final WorkspaceShortcut shortcut;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSize.componentLarge,
        height: AppSize.componentLarge,
        padding: shortcut.isSelected
            ? const EdgeInsets.all(2)
            : EdgeInsets.zero,
        decoration: shortcut.isSelected
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.red300, width: 2),
              )
            : null,
        child: CoworkAvatar(
          initials: shortcut.initial,
          size: shortcut.isSelected
              ? AppSize.componentLarge - 4
              : AppSize.componentLarge,
          backgroundColor: _backgroundColor(shortcut.color),
          foregroundColor: AppColors.white,
        ),
      ),
    );
  }

  static Color _backgroundColor(WorkspaceAvatarColor color) => switch (color) {
    WorkspaceAvatarColor.neutral => AppColors.neutral750,
    WorkspaceAvatarColor.red => AppColors.red400,
    WorkspaceAvatarColor.blue => AppColors.blue500,
    WorkspaceAvatarColor.green => AppColors.green500,
  };
}

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
                _ChannelGroupItem.type(
                  type: channel.type,
                  label: channel.name,
                  onTap: channel.type == ChannelType.chat
                      ? () => context.push(
                          '/chat/channel',
                          extra: int.parse(channel.id),
                        )
                      : null,
                ),
            ],
          ],
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
///
/// 채널뿐 아니라 데일리스크럼, 깃허브 웹훅처럼 아이콘과 탭 동작만 다른
/// 항목에도 공용으로 쓴다. [onTap]이 있으면 눌리는 행, 없으면 정적인 행이 된다.
class _ChannelGroupItem extends StatelessWidget {
  const _ChannelGroupItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  /// [type]에 맞는 기본 아이콘으로 [_ChannelGroupItem]을 만든다.
  factory _ChannelGroupItem.type({
    required ChannelType type,
    required String label,
    VoidCallback? onTap,
  }) {
    return _ChannelGroupItem(icon: _iconFor(type), label: label, onTap: onTap);
  }

  final Widget icon;
  final String label;
  final VoidCallback? onTap;

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
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: AppSpacing.s12,
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: AppSpacing.s10),
          Text(
            label,
            style: AppFont.subtextL.copyWith(color: AppColors.neutral300),
          ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
