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
  }

  void _onLoad(NotificationsRequested event, Emitter<NotificationsState> emit) {
    emit(const NotificationsState.loading());
    try {
      emit(NotificationsState.success(NotificationsStore.instance.items));
    } catch (_) {
      emit(const NotificationsState.failure());
    }
  }
}
