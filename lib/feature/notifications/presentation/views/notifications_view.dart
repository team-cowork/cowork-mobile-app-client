import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../domain/enums/avatar_color.dart';
import '../../domain/enums/notification_icon_type.dart';
import '../../domain/notification_item.dart';
import '../blocs/notifications/notifications_bloc.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<NotificationsBloc, List<NotificationItem>>(
      create: (_) => NotificationsBloc()..add(const NotificationsRequested()),
      errorTitle: '알림을 불러오지 못했어요',
      onRetry: (context) =>
          context.read<NotificationsBloc>().add(const NotificationsRequested()),
      builder: (context, items) => _NotificationsBody(items: items),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({required this.items});

  final List<NotificationItem> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NotificationsHeader(
            onBack: () => Navigator.of(context).maybePop(),
            onMarkAllRead: () => context.read<NotificationsBloc>().add(
              const NotificationsAllReadRequested(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final item in items) ...[
                    _NotificationListItem(
                      item: item,
                      onTap: () => context.read<NotificationsBloc>().add(
                        NotificationsReadRequested(id: item.id),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.neutral700,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({this.onBack, this.onMarkAllRead});

  final VoidCallback? onBack;
  final VoidCallback? onMarkAllRead;

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
        spacing: AppSpacing.s8,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const SizedBox(
              width: 32,
              height: 44,
              child: Icon(
                AppIcon.back,
                size: 24,
                color: AppColors.darkOnSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '알림',
              style: AppFont.titleS.copyWith(color: AppColors.darkOnSurface),
            ),
          ),
          GestureDetector(
            onTap: onMarkAllRead,
            child: Text(
              '모두 읽음',
              style: AppFont.labelXs.copyWith(color: AppColors.red400),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationListItem extends StatelessWidget {
  const _NotificationListItem({required this.item, this.onTap});

  final NotificationItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s14,
        ),
        decoration: BoxDecoration(
          color: item.isUnread
              ? AppColors.red400.withValues(alpha: 0.06)
              : null,
          borderRadius: BorderRadius.circular(AppRadius.r14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s12,
          children: [
            _NotificationLeading(item: item),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    item.title,
                    style: AppFont.labelXs.copyWith(
                      fontSize: 14,
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.subtextM.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
                  Text(
                    item.time,
                    style: AppFont.subtextS.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
                ],
              ),
            ),
            if (item.isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.red400,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationLeading extends StatelessWidget {
  const _NotificationLeading({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final initial = item.avatarInitial;
    if (initial != null) {
      return CoworkAvatar(
        initials: initial,
        size: 40,
        backgroundColor: _avatarColor(item.avatarColor!),
        foregroundColor: AppColors.white,
      );
    }

    final icon = item.icon!;
    final tint = _iconTint(icon);
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: _iconFor(icon),
    );
  }

  static Color _avatarColor(AvatarColor color) => switch (color) {
    AvatarColor.green => AppColors.green500,
    AvatarColor.amber => AppColors.amber500,
    AvatarColor.blue => AppColors.blue500,
    AvatarColor.red => AppColors.red400,
  };

  static Color _iconTint(NotificationIconType icon) => switch (icon) {
    NotificationIconType.taskAssigned => AppColors.blue500,
    NotificationIconType.gitPush => AppColors.green500,
  };

  static Widget _iconFor(NotificationIconType icon) => switch (icon) {
    NotificationIconType.taskAssigned => AppIcon.taskAssigned(size: 20),
    NotificationIconType.gitPush => AppIcon.gitPush(size: 20),
  };
}
