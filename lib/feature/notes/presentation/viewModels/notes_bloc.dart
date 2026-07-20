import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../../profile/data/profile_store.dart';
import '../../data/notes_store.dart';
import '../../domain/note.dart';

part 'notes_event.dart';

/// 회의록 목록 상태. 성공 시 [Note] 목록을 담는다.
typedef NotesState = AsyncState<List<Note>>;

/// 회의록 화면 상태를 관리하는 Bloc.
///
/// 현재는 목(mock) 데이터를 반환한다. 실제 API 연동 시 [_onLoad] 내부만 교체하면 된다.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc() : super(const NotesState.initial()) {
    on<NotesRequested>(_onLoad);
    on<NoteAdded>(_onAdd);
  }

  void _onLoad(
    NotesRequested event,
    Emitter<NotesState> emit,
  ) {
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
        title: event.title.trim(),
        tags: [event.template],
        summary: event.content.trim(),
        author: NoteAuthor(
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
