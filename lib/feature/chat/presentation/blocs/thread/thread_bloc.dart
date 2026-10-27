import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../data/thread_store.dart';
import '../../../domain/message_thread.dart';

part 'thread_event.dart';
part 'thread_state.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  ThreadBloc() : super(const ThreadState.initial()) {
    on<ThreadRequested>(_onLoad);
  }

  void _onLoad(ThreadRequested event, Emitter<ThreadState> emit) {
    emit(const ThreadState.loading());
    try {
      emit(ThreadState.success(ThreadStore.instance.thread));
    } catch (_) {
      emit(const ThreadState.failure());
    }
  }
}
