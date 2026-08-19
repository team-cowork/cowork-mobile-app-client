import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/notification_item.dart';
import '../viewModels/notifications_bloc.dart';
import 'notification_list_item.dart';
import 'notifications_header.dart';

class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key, required this.items});

  final List<NotificationItem> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NotificationsHeader(
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
                    NotificationListItem(item: item),
                    const Divider(height: 1, thickness: 1, color: AppColors.neutral700),
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
