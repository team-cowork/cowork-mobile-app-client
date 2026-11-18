import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class TeamMenuSheet extends StatelessWidget {
  const TeamMenuSheet({
    required this.teamName,
    this.canInviteMembers = true,
    this.onOpenSettings,
    this.onInviteMembers,
    this.onCreateChannel,
    this.onCreateProject,
    this.onLeaveTeam,
    super.key,
  });

  final String teamName;

  /// '멤버 초대' 를 보일지. 초대 권한(`manage_invites`)이 없으면 숨긴다.
  final bool canInviteMembers;

  /// '팀 설정' 을 눌렀을 때. 시트가 닫힌 뒤에 불린다.
  final VoidCallback? onOpenSettings;

  /// '멤버 초대' 를 눌렀을 때. 시트가 닫힌 뒤에 불린다.
  final VoidCallback? onInviteMembers;

  /// '채널 만들기' 를 눌렀을 때. 시트가 닫힌 뒤에 불린다.
  final VoidCallback? onCreateChannel;

  /// '카테고리 만들기' 를 눌렀을 때. 시트가 닫힌 뒤에 불린다.
  final VoidCallback? onCreateProject;

  /// '팀 나가기' 를 눌렀을 때. 시트가 닫힌 뒤에 불린다.
  ///
  /// null 이면 항목을 숨긴다. 소유자는 소유권을 넘기기 전엔 나갈 수 없다.
  final VoidCallback? onLeaveTeam;

  static const double _sheetRadius = 20;

  static Future<void> show(
    BuildContext context, {
    required String teamName,
    bool canInviteMembers = true,
    VoidCallback? onOpenSettings,
    VoidCallback? onInviteMembers,
    VoidCallback? onCreateChannel,
    VoidCallback? onCreateProject,
    VoidCallback? onLeaveTeam,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.neutral800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
      ),
      builder: (_) => TeamMenuSheet(
        teamName: teamName,
        canInviteMembers: canInviteMembers,
        onOpenSettings: onOpenSettings,
        onInviteMembers: onInviteMembers,
        onCreateChannel: onCreateChannel,
        onCreateProject: onCreateProject,
        onLeaveTeam: onLeaveTeam,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.s8,
          bottom: AppSpacing.s24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              decoration: BoxDecoration(
                color: AppColors.neutral400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s6,
                AppSpacing.s16,
                AppSpacing.s12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      teamName,
                      style: AppFont.labelM.copyWith(
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      AppIcon.close,
                      size: 24,
                      color: AppColors.neutral300,
                    ),
                  ),
                ],
              ),
            ),
            _MenuRow(emoji: '⚙️', label: '팀 설정', onSelected: onOpenSettings),
            if (canInviteMembers)
              _MenuRow(emoji: '➕', label: '멤버 초대', onSelected: onInviteMembers),
            _MenuRow(emoji: '#', label: '채널 만들기', onSelected: onCreateChannel),
            _MenuRow(
              emoji: '📁',
              label: '카테고리 만들기',
              onSelected: onCreateProject,
            ),
            // '알림 설정' 은 뺐다. 서버에 "이 팀에 대한 내 알림" API 가 없다(#150).
            if (onLeaveTeam case final onLeaveTeam?) ...[
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.neutral600,
              ),
              _MenuRow(
                emoji: '🚪',
                label: '팀 나가기',
                destructive: true,
                onSelected: onLeaveTeam,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.emoji,
    required this.label,
    this.onSelected,
    this.destructive = false,
  });

  final String emoji;
  final String label;

  /// 시트를 닫은 뒤에 불린다. 없으면 닫히기만 한다.
  final VoidCallback? onSelected;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onSelected?.call();
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        child: Row(
          spacing: AppSpacing.s14,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            Text(
              label,
              style: AppFont.labelS.copyWith(
                color: destructive ? AppColors.red400 : AppColors.darkOnSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
