import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/logger.dart';
import '../../../../network/http_error_message.dart';
import '../../data/notes_repository.dart';
import '../../domain/note.dart';

part 'notes_event.dart';

/// 회의록 목록 상태. 성공 시 [Note] 목록을 담는다.
typedef NotesState = AsyncState<List<Note>>;

/// 회의록 화면 상태를 관리하는 Bloc.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc(this._repository) : super(const NotesState.initial()) {
    on<NotesRequested>(_onLoad);
    on<NoteAdded>(_onAdd);
  }

  final NotesRepository _repository;

  Future<void> _onLoad(
    NotesRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesState.loading());
    try {
      emit(NotesState.success(await _repository.fetchNotes()));
    } catch (e, s) {
      Logger.e('회의록 조회 실패', tag: 'Notes', error: e, stackTrace: s);
      emit(NotesState.failure(e is DioException ? dioErrorMessage(e) : null));
    }
  }

  /// 새 회의록을 서버에 쓰고 목록을 다시 읽는다.
  ///
  /// 작성자·작성일은 서버가 채우므로 응답을 기다렸다가 목록째 갱신한다.
  Future<void> _onAdd(NoteAdded event, Emitter<NotesState> emit) async {
    emit(const NotesState.loading());
    try {
      await _repository.createNote(
        title: event.title.trim(),
        summary: event.content.trim(),
      );
      emit(NotesState.success(await _repository.fetchNotes()));
    } catch (e, s) {
      Logger.e('회의록 작성 실패', tag: 'Notes', error: e, stackTrace: s);
      emit(
        NotesState.failure(
          e is DioException ? dioErrorMessage(e) : '회의록을 저장하지 못했어요.',
        ),
      );
    }
  }
}

/// 새 노트 시트의 입력 상태.
class NewNoteForm extends Equatable {
  const NewNoteForm({this.title = '', this.content = '', this.template = 0});

  final String title;
  final String content;

  /// 선택된 템플릿 인덱스.
  final int template;

  /// 제목이 있어야 노트를 만들 수 있다.
  bool get canSubmit => title.trim().isNotEmpty;

  NewNoteForm copyWith({String? title, String? content, int? template}) =>
      NewNoteForm(
        title: title ?? this.title,
        content: content ?? this.content,
        template: template ?? this.template,
      );

  @override
  List<Object?> get props => [title, content, template];
}

/// 새 노트 시트의 입력 상태를 관리하는 Bloc.
///
/// 목록([NotesBloc])과 수명이 달라 별도 Bloc으로 둔다. 시트가 닫히면 함께 버려진다.
class NewNoteBloc extends Bloc<NewNoteEvent, NewNoteForm> {
  NewNoteBloc() : super(const NewNoteForm()) {
    on<NewNoteChanged>(
      (event, emit) => emit(
        state.copyWith(
          title: event.title,
          content: event.content,
          template: event.template,
        ),
      ),
    );
  }
}
