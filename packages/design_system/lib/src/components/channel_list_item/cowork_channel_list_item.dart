import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class CoworkChannelListItem extends StatelessWidget {
  const CoworkChannelListItem({
    super.key,
    required this.channelName,
    required this.unreadCount,
  });

  final String channelName;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;
    final countLabel = unreadCount > 99 ? '99+' : '$unreadCount';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.s12),
            AppIcon.hashChannel(),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                '# $channelName',
                style: AppFont.labelM,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasUnread) ...[
              const SizedBox(width: AppSpacing.s8),
              _UnreadCountBadge(label: countLabel),
              const SizedBox(width: AppSpacing.s12),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnreadCountBadge extends StatelessWidget {
  const _UnreadCountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      width: 28,
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppFont.itemCount.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}