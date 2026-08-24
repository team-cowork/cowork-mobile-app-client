import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/notes_store.dart';
import '../../../domain/note.dart';

part 'note_edit_event.dart';
part 'note_edit_state.dart';

/// 회의록 편집 화면의 저장 흐름을 관리하는 Bloc.
///
/// 편집 대상 [Note]를 주입받아, 저장 시 변경된 필드로 노트를 만들어 저장소에 반영한다.
/// 실제 API 연동 시 [_onSave]의 저장 호출만 교체하면 된다.
class NoteEditBloc extends Bloc<NoteEditEvent, NoteEditState> {
  NoteEditBloc(Note note) : super(NoteEditState(note: note)) {
    on<NoteEditSaved>(_onSave);
  }

  void _onSave(NoteEditSaved event, Emitter<NoteEditState> emit) {
    final updated = state.note.copyWith(
      title: event.title,
      summary: event.summary,
      agenda: event.agenda,
      decisions: event.decisions,
      actionItems: event.actionItems,
    );
    NotesStore.instance.update(updated);
    emit(NoteEditState(note: updated, saved: true));
  }
}
