import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../data/notifications_store.dart';
import '../../domain/notification_item.dart';

part 'notifications_event.dart';

typedef NotificationsState = AsyncState<List<NotificationItem>>;

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(const NotificationsState.initial()) {
    on<NotificationsRequested>(_onLoad);
    on<NotificationsAllReadRequested>(_onAllRead);
    on<NotificationsReadRequested>(_onRead);
  }

  void _onLoad(NotificationsRequested event, Emitter<NotificationsState> emit) {
    emit(const NotificationsState.loading());
    try {
      emit(NotificationsState.success(NotificationsStore.instance.items));
    } catch (_) {
      emit(const NotificationsState.failure());
    }
  }

  void _onAllRead(
    NotificationsAllReadRequested event,
    Emitter<NotificationsState> emit,
  ) {
    final current = state;
    if (current is! AsyncSuccess<List<NotificationItem>>) return;

    emit(
      NotificationsState.success([
        for (final item in current.data) item.copyWith(isUnread: false),
      ]),
    );
  }

  void _onRead(
    NotificationsReadRequested event,
    Emitter<NotificationsState> emit,
  ) {
    final current = state;
    if (current is! AsyncSuccess<List<NotificationItem>>) return;

    emit(
      NotificationsState.success([
        for (final item in current.data)
          if (item.id == event.id) item.copyWith(isUnread: false) else item,
      ]),
    );
  }
}
