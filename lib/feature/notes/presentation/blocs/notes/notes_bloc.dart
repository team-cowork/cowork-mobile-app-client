import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../../profile/data/profile_store.dart';
import '../../../data/notes_store.dart';
import '../../../domain/note.dart';

part 'notes_event.dart';
part 'notes_state.dart';

/// 회의록 화면 상태를 관리하는 Bloc.
///
/// 현재는 목(mock) 데이터를 반환한다. 실제 API 연동 시 [_onLoad] 내부만 교체하면 된다.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc() : super(const NotesState.initial()) {
    on<NotesRequested>(_onLoad);
    on<NoteAdded>(_onAdd);
  }

  void _onLoad(NotesRequested event, Emitter<NotesState> emit) {
    emit(const NotesState.loading());
    try {
      emit(NotesState.success(NotesStore.instance.notes));
    } catch (_) {
      emit(const NotesState.failure());
    }
  }

  /// 새 노트를 로컬 저장소에 추가하고 목록을 갱신한다.
  ///
  /// 작성자는 현재 로그인 사용자([ProfileStore])로 채운다.
  /// 실제 API 연동 시 저장 호출만 교체하면 된다.
  void _onAdd(NoteAdded event, Emitter<NotesState> emit) {
    final now = DateTime.now();
    final profile = ProfileStore.instance;

    NotesStore.instance.add(
      Note(
        id: NotesStore.instance.nextId,
        title: event.title.trim(),
        tags: [event.template],
        summary: event.content.trim(),
        author: NoteAuthor(
          authorId: profile.currentUserId,
          name: profile.name,
          initial: profile.avatarInitial,
          avatarUrl: profile.avatarUrl,
          date:
              '${now.month.toString().padLeft(2, '0')}.'
              '${now.day.toString().padLeft(2, '0')}',
        ),
      ),
    );

    emit(NotesState.success(NotesStore.instance.notes));
  }
}
