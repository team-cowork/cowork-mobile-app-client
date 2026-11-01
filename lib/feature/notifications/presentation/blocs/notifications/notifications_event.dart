part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  const factory NotificationsEvent.requested() = NotificationsRequested;

  const factory NotificationsEvent.allReadRequested() =
      NotificationsAllReadRequested;

  const factory NotificationsEvent.readRequested({required String id}) =
      NotificationsReadRequested;

  @override
  List<Object?> get props => [];
}

final class NotificationsRequested extends NotificationsEvent {
  const NotificationsRequested();
}

final class NotificationsAllReadRequested extends NotificationsEvent {
  const NotificationsAllReadRequested();
}

final class NotificationsReadRequested extends NotificationsEvent {
  const NotificationsReadRequested({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

/// 저장소의 알림 목록이 바뀌었다. 화면이 아니라 Bloc 이 스스로 넣는다.
final class _NotificationsChanged extends NotificationsEvent {
  const _NotificationsChanged();
}
