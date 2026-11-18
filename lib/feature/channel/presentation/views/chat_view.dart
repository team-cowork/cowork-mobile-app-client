import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/chat_socket.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../notifications/data/repositories/notification_repository.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../project/data/repositories/project_repository.dart';
import '../../../team/data/repositories/team_repository.dart';
import '../../../team/presentation/widgets/add_team_sheet.dart';
import '../../../team/presentation/widgets/join_team_sheet.dart';
import '../../../team/presentation/widgets/new_team_sheet.dart';
import '../../../team/presentation/widgets/team_action_dialog.dart';
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
        context.read<ProjectRepository>(),
        context.read<ChatSocket>(),
        profileRepository: context.read<ProfileRepository>(),
        invitedTeams: context.read<NotificationRepository>().invitedTeamIds,
      )..add(const ChannelListRequested()),
      // 어느 단계(팀/채널)가 실패했는지는 설명 문구에 실려 온다. (#94)
      errorTitle: '홈을 불러오지 못했어요',
      onRetry: (context) =>
          context.read<ChannelListBloc>().add(const ChannelListRequested()),
      builder: (context, data) => switch (data.teamId) {
        // 팀이 없어도 단축 바는 둔다. 팀 생성·참여 진입점을 `+` 하나로 맞추려는 것이다.
        null => SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 팀이 없어도 초대 알림을 볼 수 있게 알림만 둔다. 자리는 헤더와 맞춘다.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s6,
                  AppSpacing.s16,
                  AppSpacing.s12,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Semantics(
                    label: '알림',
                    button: true,
                    child: GestureDetector(
                      onTap: () => _openNotifications(context),
                      child: AppIcon.bell(),
                    ),
                  ),
                ),
              ),
              _ChatShortcutBar(
                shortcuts: const [],
                onDmHomeTap: () => context.push('/dm'),
                onAddTeam: () => _addTeam(context),
              ),
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s16),
                    child: CoworkEmptyState(
                      icon: Icons.groups_outlined,
                      title: '아직 속한 팀이 없어요',
                      description: '+ 로 팀을 만들거나 초대 코드로 참여하면 채널이 여기에 보여요.',
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
                  canInviteMembers: data.canInviteMembers,
                  onOpenSettings: () => _openTeamSettings(context, teamId),
                  onInviteMembers: () => context.push('/teams/$teamId/invite'),
                  onCreateChannel: () => _createChannel(context, teamId),
                  onCreateProject: () => _createProject(context, teamId),
                  // 소유자는 소유권을 넘기기 전엔 나갈 수 없다(서버 403).
                  onLeaveTeam: data.isTeamOwner
                      ? null
                      : () => _leaveTeam(context, teamId, data.workspaceName),
                ),
                onSearchTap: () => context.push('/search?teamId=$teamId'),
                onNotificationTap: () => _openNotifications(context),
              ),
              _ChatShortcutBar(
                shortcuts: data.workspaceShortcuts,
                onDmHomeTap: () => context.push('/dm'),
                onTeamTap: (id) => context.read<ChannelListBloc>().add(
                  ChannelListEvent.teamSelected(id),
                ),
                onAddTeam: () => _addTeam(context),
              ),
              Expanded(
                child: _ChannelList(
                  channelGroups: data.channelGroups,
                  onCreateChannelIn: (projectId) =>
                      _createChannel(context, teamId, projectId: projectId),
                ),
              ),
            ],
          ),
        ),
      },
    );
  }

  /// 알림 화면을 연다. 팀 알림을 눌러 닫히면 그 팀으로 옮긴다.
  static Future<void> _openNotifications(BuildContext context) async {
    final bloc = context.read<ChannelListBloc>();
    final teamId = await context.push<int>('/notifications');
    // 알림 화면에 있는 동안 홈이 사라졌으면(로그아웃 등) 옮길 곳이 없다.
    if (teamId != null && !bloc.isClosed) {
      bloc.add(ChannelListEvent.teamSelected(teamId));
    }
  }

  /// 팀을 만들지 초대 코드로 참여할지 고르게 하고, 고른 시트를 띄운다.
  static Future<void> _addTeam(BuildContext context) async {
    final choice = await AddTeamSheet.show(context);
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case AddTeamChoice.create:
        await _createTeam(context);
      case AddTeamChoice.join:
        await _joinTeam(context);
    }
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

  /// 팀 설정 화면을 연다. 돌아오면 팀이 지워졌는지, 이름이 바뀌었는지 홈에 반영한다.
  static Future<void> _openTeamSettings(
    BuildContext context,
    int teamId,
  ) async {
    final bloc = context.read<ChannelListBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final deleted = await context.push<bool>('/teams/$teamId/settings');
    if (bloc.isClosed) return;
    if (deleted == true) {
      bloc.add(ChannelListEvent.teamLeft(teamId));
      messenger.showSnackBar(const SnackBar(content: Text('팀을 삭제했어요.')));
    } else {
      // 설정 화면은 바꾸는 즉시 저장해 돌아올 때 따로 결과를 주지 않는다.
      bloc.add(const ChannelListEvent.teamsRefreshed());
    }
  }

  /// 팀을 나갈지 묻고, 나갔으면 다른 팀으로 옮기고 알린다.
  static Future<void> _leaveTeam(
    BuildContext context,
    int teamId,
    String teamName,
  ) async {
    final bloc = context.read<ChannelListBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final teams = context.read<TeamRepository>();
    final profile = context.read<ProfileRepository>();
    final left = await TeamActionDialog.show(
      context,
      title: '팀에서 나갈까요?',
      message: '팀의 모든 채널과 대화에 접근할 수 없게 되며, 다시 참여하려면 초대를 받아야 해요.',
      confirmLabel: '나가기',
      runningLabel: '나가는 중…',
      failureTitle: '팀을 나가지 못했어요.',
      action: () async => teams.leaveTeam(teamId, await profile.fetchMyId()),
    );
    if (!left || bloc.isClosed) return;
    bloc.add(ChannelListEvent.teamLeft(teamId));
    messenger.showSnackBar(SnackBar(content: Text('$teamName 팀에서 나왔어요.')));
  }

  /// 초대 코드 시트를 띄우고, 참여하면 그 팀으로 옮기고 알린다.
  ///
  /// 참여 응답에는 팀 이름이 없다. [ChannelListEvent.teamSelected] 는 모르는 팀이면
  /// 팀 목록을 다시 읽어 찾으므로, 알림으로 들어온 팀과 같은 길로 옮긴다.
  static Future<void> _joinTeam(BuildContext context) async {
    final bloc = context.read<ChannelListBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final joined = await JoinTeamSheet.show(context);
    if (joined == null || bloc.isClosed) return;
    bloc.add(ChannelListEvent.teamSelected(joined.teamId));
    messenger.showSnackBar(const SnackBar(content: Text('팀에 참여했어요.')));
  }

  /// 채널 생성 시트를 띄우고, 만들어지면 목록에 붙이고 알린다.
  ///
  /// [projectId] 를 주면 그 프로젝트에 넣는다. 채널은 만들었지만 프로젝트에 넣지
  /// 못했으면 채널은 프로젝트 밖에 보이고, 그 사실을 알린다.
  static Future<void> _createChannel(
    BuildContext context,
    int teamId, {
    int? projectId,
  }) async {
    final bloc = context.read<ChannelListBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final result = await NewChannelSheet.show(
      context,
      teamId: teamId,
      projectId: projectId,
    );
    if (result == null) return;
    final (:channel, :projectFailed) = result;
    bloc.add(ChannelListEvent.channelAdded(channel));
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          projectFailed
              ? '#${channel.name} 채널을 만들었지만 프로젝트에 넣지 못했어요.'
              : '#${channel.name} 채널을 만들었어요.',
        ),
      ),
    );
  }

  /// 프로젝트 생성 시트를 띄우고, 만들어지면 빈 그룹으로 붙이고 알린다.
  static Future<void> _createProject(BuildContext context, int teamId) async {
    final bloc = context.read<ChannelListBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final project = await NewProjectSheet.show(context, teamId: teamId);
    if (project == null || bloc.isClosed) return;
    bloc.add(ChannelListEvent.projectAdded(project));
    messenger.showSnackBar(
      SnackBar(content: Text('${project.name} 프로젝트를 만들었어요.')),
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
    this.onAddTeam,
  });

  final List<WorkspaceShortcut> shortcuts;

  /// DM 홈 버튼을 눌렀을 때.
  final VoidCallback? onDmHomeTap;

  /// 팀 아바타를 눌렀을 때. 누른 팀 id 를 넘긴다.
  final ValueChanged<int>? onTeamTap;

  /// 팀 목록 끝 `+` 를 눌렀을 때. 웹 팀 레일의 `팀 추가` 와 같은 자리다.
  final VoidCallback? onAddTeam;

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
              semanticLabel: '팀 추가',
              onPressed: onAddTeam,
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
  const _ChannelList({
    required this.channelGroups,
    required this.onCreateChannelIn,
  });

  final List<ChannelGroup> channelGroups;

  /// 프로젝트 그룹 헤더의 `+` 를 눌렀을 때. 그 프로젝트 id 를 넘긴다.
  final ValueChanged<int> onCreateChannelIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      child: SingleChildScrollView(
        child: Column(
          spacing: AppSpacing.s4,
          children: [
            for (final group in channelGroups) ...[
              _ChannelGroupHeader(
                label: group.name,
                // 프로젝트 밖 채널은 팀 메뉴의 `채널 만들기` 로 만든다.
                onAdd: switch (group.projectId) {
                  final projectId? => () => onCreateChannelIn(projectId),
                  null => null,
                },
              ),
              for (final channel in group.channels)
                _ChannelGroupItem.type(
                  type: channel.type,
                  label: channel.name,
                  onTap: channel.type == ChannelType.chat
                      ? () => context.push('/chat/channel/${channel.id}')
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
  const _ChannelGroupHeader({required this.label, this.onAdd});

  final String label;

  /// 이 그룹에 채널을 만든다. 있으면 오른쪽 끝에 `+` 를 둔다.
  final VoidCallback? onAdd;

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
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFont.itemCount.copyWith(color: AppColors.neutral300),
            ),
          ),
          if (onAdd case final onAdd?)
            Semantics(
              label: '$label 에 채널 만들기',
              button: true,
              child: InkWell(
                onTap: onAdd,
                customBorder: const CircleBorder(),
                // 아이콘은 작아도 누르는 영역은 넉넉히 둔다.
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s4,
                  ),
                  child: AppIcon.plus(size: 12),
                ),
              ),
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
