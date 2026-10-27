import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/notes_repository.dart';
import '../../../domain/note.dart';

part 'note_edit_event.dart';
part 'note_edit_state.dart';

/// 회의록 편집 화면의 저장 흐름을 관리하는 Bloc.
///
/// 편집 대상 [Note]를 주입받아, 저장 시 변경된 필드로 노트를 만들어 서버에 올린다.
class NoteEditBloc extends Bloc<NoteEditEvent, NoteEditState> {
  NoteEditBloc(Note note, this._repository) : super(NoteEditState(note: note)) {
    on<NoteEditSaved>(_onSave);
  }

  final NotesRepository _repository;

  Future<void> _onSave(NoteEditSaved event, Emitter<NoteEditState> emit) async {
    final updated = state.note.copyWith(
      title: event.title,
      summary: event.summary,
      agenda: event.agenda,
      decisions: event.decisions,
      actionItems: event.actionItems,
    );
    // 지난 실패 사유를 먼저 지운다. 같은 사유로 또 실패하면 상태가 같아 화면이
    // 다시 알림을 띄우지 못하기 때문이다.
    emit(NoteEditState(note: state.note));
    try {
      await _repository.updateNote(updated);
      emit(NoteEditState(note: updated, saved: true));
    } catch (e, s) {
      Logger.e('회의록 저장 실패', tag: 'Notes', error: e, stackTrace: s);
      emit(
        NoteEditState(
          note: state.note,
          error: e is DioException ? dioErrorMessage(e) : '회의록을 저장하지 못했어요.',
        ),
      );
    }
  }
}
