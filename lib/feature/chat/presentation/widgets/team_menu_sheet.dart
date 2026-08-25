import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class TeamMenuSheet extends StatelessWidget {
  const TeamMenuSheet({required this.teamName, super.key});

  final String teamName;

  static const double _sheetRadius = 20;

  static Future<void> show(BuildContext context, {required String teamName}) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.neutral800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
      ),
      builder: (_) => TeamMenuSheet(teamName: teamName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s8, bottom: AppSpacing.s24),
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
            const _MenuRow(emoji: '⚙️', label: '팀 설정'),
            const _MenuRow(emoji: '➕', label: '멤버 초대'),
            const _MenuRow(emoji: '#', label: '채널 만들기'),
            const _MenuRow(emoji: '📁', label: '카테고리 만들기'),
            const _MenuRow(emoji: '🔔', label: '알림 설정'),
            const Divider(height: 1, thickness: 1, color: AppColors.neutral600),
            const _MenuRow(emoji: '🚪', label: '팀 나가기', destructive: true),
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
    this.destructive = false,
  });

  final String emoji;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
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
