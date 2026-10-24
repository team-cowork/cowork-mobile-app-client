import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../data/model/notification_item_mapping.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../domain/notification_item.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// 알림 화면 상태를 관리하는 Bloc.
///
/// 알림은 앱 전체에서 [NotificationRepository] 가 SSE 로 받아 쌓는다. 화면은 그 목록을
/// 보여 주고, 화면을 연 동안 새로 온 알림은 바로 위에 붙는다.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(this._repository)
    : super(const NotificationsState.initial()) {
    on<NotificationsRequested>(_onLoad);
    on<NotificationsAllReadRequested>(_onAllRead);
    on<NotificationsReadRequested>(_onRead);
    on<_NotificationsChanged>(_onChanged);

    _changes = _repository.changes.listen(
      (_) => add(const _NotificationsChanged()),
    );
  }

  final NotificationRepository _repository;
  late final StreamSubscription<void> _changes;

  void _onLoad(NotificationsRequested event, Emitter<NotificationsState> emit) {
    _emit(emit);
  }

  void _onAllRead(
    NotificationsAllReadRequested event,
    Emitter<NotificationsState> emit,
  ) => _repository.markAllRead();

  void _onRead(
    NotificationsReadRequested event,
    Emitter<NotificationsState> emit,
  ) => _repository.markRead(event.id);

  void _onChanged(
    _NotificationsChanged event,
    Emitter<NotificationsState> emit,
  ) {
    if (state is AsyncSuccess<List<NotificationItem>>) _emit(emit);
  }

  void _emit(Emitter<NotificationsState> emit) {
    final now = DateTime.now();
    emit(
      NotificationsState.success([
        for (final item in _repository.items)
          notificationItemOf(item, now: now),
      ]),
    );
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
