import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../domain/notification_item.dart';
import '../viewModels/notifications_bloc.dart';
import '../widgets/notifications_body.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<NotificationsBloc, List<NotificationItem>>(
      create: (_) => NotificationsBloc()..add(const NotificationsRequested()),
      errorTitle: '알림을 불러오지 못했어요',
      onRetry: (context) =>
          context.read<NotificationsBloc>().add(const NotificationsRequested()),
      builder: (context, items) => NotificationsBody(items: items),
    );
  }
}
