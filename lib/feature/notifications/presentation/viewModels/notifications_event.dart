part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  const factory NotificationsEvent.requested() = NotificationsRequested;

  const factory NotificationsEvent.allReadRequested() =
      NotificationsAllReadRequested;

  @override
  List<Object?> get props => [];
}

final class NotificationsRequested extends NotificationsEvent {
  const NotificationsRequested();
}

final class NotificationsAllReadRequested extends NotificationsEvent {
  const NotificationsAllReadRequested();
}
