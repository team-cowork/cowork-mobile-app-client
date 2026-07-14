import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/notes_store.dart';
import '../../domain/note.dart';

part 'notes_event.dart';
part 'notes_state.dart';

/// 회의록 화면 상태를 관리하는 Bloc.
///
/// 현재는 목(mock) 데이터를 반환한다. 실제 API 연동 시 [_onLoad] 내부만 교체하면 된다.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc() : super(const NotesState.initial()) {
    on<NotesRequested>(_onLoad);
  }

  Future<void> _onLoad(
    NotesRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesState.loading());
    try {
      emit(NotesState.success(NotesStore.instance.notes));
    } catch (_) {
      emit(const NotesState.failure());
    }
  }
}
