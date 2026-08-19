import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../../../network/http_error_message.dart';
import '../../data/notes_repository.dart';
import '../../domain/note.dart';

part 'note_edit_event.dart';

/// 회의록 편집 화면 상태.
///
/// 편집 중인 노트를 들고 있다가, 저장하면 갱신된 노트로 교체하고 [saved]를 세워
/// 화면을 닫도록 뷰에 알린다.
class NoteEditState extends Equatable {
  const NoteEditState({required this.note, this.saved = false, this.error});

  final Note note;

  /// 저장이 끝났다는 신호. true가 되면 편집 화면을 닫고 갱신된 노트를 돌려준다.
  final bool saved;

  /// 저장 실패 사유. 화면이 그대로 보여준다.
  final String? error;

  @override
  List<Object?> get props => [note, saved, error];
}

/// 회의록 편집 화면의 저장 흐름을 관리하는 Bloc.
///
/// 편집 대상 [Note]를 주입받아, 저장 시 변경된 필드로 노트를 만들어 서버에 올린다.
class NoteEditBloc extends Bloc<NoteEditEvent, NoteEditState> {
  NoteEditBloc(Note note, this._repository) : super(NoteEditState(note: note)) {
    on<NoteEditSaved>(_onSave);
  }

  final NotesRepository _repository;

  Future<void> _onSave(
    NoteEditSaved event,
    Emitter<NoteEditState> emit,
  ) async {
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
