import 'package:equatable/equatable.dart';

import 'responses/notification_event_response.dart';

/// 이 앱이 켜져 있는 동안 받은 알림 하나.
class ReceivedNotification extends Equatable {
  const ReceivedNotification({
    required this.id,
    required this.event,
    required this.receivedAt,
    this.read = false,
  });

  /// 앱 안에서만 쓰는 id. 서버 알림에는 id 가 없다.
  final String id;
  final NotificationEventResponse event;
  final DateTime receivedAt;
  final bool read;

  ReceivedNotification markRead() => ReceivedNotification(
    id: id,
    event: event,
    receivedAt: receivedAt,
    read: true,
  );

  @override
  List<Object?> get props => [id, event, receivedAt, read];
}
