import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/notes_repository.dart';
import '../../../data/repositories/note_template_repository.dart';
import '../../../domain/note.dart';
import '../../../domain/note_draft.dart';
import '../../../domain/note_section_field.dart';
import '../../../domain/note_template.dart';

part 'note_edit_event.dart';
part 'note_edit_state.dart';

/// 회의록 편집 화면의 입력 칸과 저장 흐름을 관리하는 Bloc.
///
/// 회의록이 쓴 템플릿을 읽어 섹션 순서·형식·필수 여부대로 입력 칸을 만들고, 저장
/// 시 필수 섹션을 확인한 뒤 서버에 올린다. 새 회의록이면 그때 만든다.
class NoteEditBloc extends Bloc<NoteEditEvent, NoteEditState> {
  /// 이미 있는 [note] 를 고친다. 템플릿은 [NoteEditStarted] 때 읽는다.
  NoteEditBloc(
    Note note,
    NotesRepository repository,
    NoteTemplateRepository templates,
  ) : this._(note, null, repository, templates);

  /// 새 노트 시트에서 고른 [draft] 로 새 회의록을 쓴다. [author] 는 메타 줄에 보일
  /// 로그인 사용자다. 서버에는 처음 저장할 때 만들므로 그 전까지 id 는 0 이다.
  NoteEditBloc.create(
    NoteDraft draft,
    NoteAuthor author,
    NotesRepository repository,
    NoteTemplateRepository templates,
  ) : this._(
        Note(
          id: 0,
          channelId: draft.channelId,
          templateId: draft.template.id,
          title: draft.title,
          tags: const [],
          author: author,
        ),
        draft.template,
        repository,
        templates,
      );

  NoteEditBloc._(
    Note note,
    this._draftTemplate,
    this._repository,
    this._templates,
  ) : super(NoteEditState(note: note)) {
    on<NoteEditStarted>(_onStart);
    on<NoteEditSaved>(_onSave);
  }

  /// 새 회의록이면 시트에서 고른 템플릿. 이미 있는 회의록이면 null 이다.
  final NoteTemplate? _draftTemplate;

  final NotesRepository _repository;
  final NoteTemplateRepository _templates;

  /// 저장 요청이 오가는 중인지. 새 회의록에서 저장을 연달아 누르면 회의록이 둘
  /// 생기므로 그동안 들어온 저장은 버린다.
  bool _saving = false;

  bool get _isNew => _draftTemplate != null;

  /// 템플릿을 못 읽어도 편집은 막지 않는다. 본문에 있는 섹션은 그대로 고칠 수 있다.
  Future<void> _onStart(
    NoteEditStarted event,
    Emitter<NoteEditState> emit,
  ) async {
    final note = state.note;
    var template = _draftTemplate;
    if (template == null) {
      try {
        template = await _templates.fetchTemplate(
          note.channelId,
          note.templateId,
        );
      } catch (e, s) {
        Logger.e('회의록 템플릿 조회 실패', tag: 'Notes', error: e, stackTrace: s);
      }
    }
    emit(
      NoteEditState(
        note: note,
        fields: sectionFieldsOf(template, note.sections),
        templateName: template?.name,
        templateMissing: template == null,
      ),
    );
  }

  Future<void> _onSave(NoteEditSaved event, Emitter<NoteEditState> emit) async {
    if (_saving) return;

    // 지난 실패 사유를 먼저 지운다. 같은 사유로 또 실패하면 상태가 같아 화면이
    // 다시 알림을 띄우지 못하기 때문이다.
    emit(state.copyWith());

    // 서버는 필수 섹션을 검사하지 않으므로 여기서 막는다.
    final missing = [
      for (final field in state.fields ?? const <NoteSectionField>[])
        if (field.isRequired &&
            (event.sections[field.title] ?? '').trim().isEmpty)
          field.title,
    ];
    if (missing.isNotEmpty) {
      emit(state.copyWith(error: '필수 섹션을 채워 주세요: ${missing.join(', ')}'));
      return;
    }

    var edited = state.note.copyWith(
      title: event.title,
      // 빈 섹션은 빼서 서버에 빈 키가 쌓이지 않게 한다.
      sections: {
        for (final MapEntry(:key, :value) in event.sections.entries)
          if (value.trim().isNotEmpty) key: value,
      },
    );
    _saving = true;
    try {
      if (_isNew) {
        // 서버가 정한 id·작성자로 바꿔 둔다. 화면을 닫으며 이 회의록을 돌려준다.
        edited = await _repository.createNote(edited);
      } else {
        await _repository.updateNote(edited);
      }
      emit(state.copyWith(note: edited, saved: true));
    } catch (e, s) {
      Logger.e('회의록 저장 실패', tag: 'Notes', error: e, stackTrace: s);
      emit(
        state.copyWith(
          error: e is DioException ? dioErrorMessage(e) : '회의록을 저장하지 못했어요.',
        ),
      );
    } finally {
      _saving = false;
    }
  }
}
