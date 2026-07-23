import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/notes_store.dart';
import '../../domain/note.dart';

part 'note_edit_event.dart';

/// 회의록 편집 화면 상태.
///
/// 편집 중인 노트를 들고 있다가, 저장하면 갱신된 노트로 교체하고 [saved]를 세워
/// 화면을 닫도록 뷰에 알린다.
class NoteEditState extends Equatable {
  const NoteEditState({required this.note, this.saved = false});

  final Note note;

  /// 저장이 끝났다는 신호. true가 되면 편집 화면을 닫고 갱신된 노트를 돌려준다.
  final bool saved;

  @override
  List<Object?> get props => [note, saved];
}

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
