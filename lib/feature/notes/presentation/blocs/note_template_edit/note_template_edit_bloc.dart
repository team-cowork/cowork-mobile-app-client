import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/repositories/note_template_repository.dart';
import '../../../domain/note_template.dart';

part 'note_template_edit_event.dart';
part 'note_template_edit_state.dart';

/// 템플릿 편집 화면 상태를 관리하는 Bloc.
///
/// 이름·섹션 입력은 시트가 직접 서버에 보내고 결과만 넘긴다. 시트가 닫히면 입력값과
/// 실패 사유를 보여줄 곳이 없어서다. 입력 없이 바로 보내는 기본 설정·삭제는 여기서
/// 보낸다.
class NoteTemplateEditBloc
    extends Bloc<NoteTemplateEditEvent, NoteTemplateEditState> {
  NoteTemplateEditBloc(NoteTemplate template, this._repository)
    : super(NoteTemplateEditState(template: template)) {
    on<NoteTemplateChanged>(
      (event, emit) => emit(state.copyWith(template: event.template)),
    );
    on<NoteTemplateSectionSaved>(_onSectionSaved);
    on<NoteTemplateSectionDeleted>(_onSectionDeleted);
    on<NoteTemplateDefaultRequested>(_onDefault);
    on<NoteTemplateDeleteRequested>(_onDelete);
  }

  final NoteTemplateRepository _repository;

  /// 같은 id 가 있으면 고친 섹션이고, 없으면 끝에 추가한 섹션이다.
  void _onSectionSaved(
    NoteTemplateSectionSaved event,
    Emitter<NoteTemplateEditState> emit,
  ) {
    final sections = state.template.sections;
    final saved = event.section;
    emit(
      state.copyWith(
        template: state.template.copyWith(
          sections: sections.any((section) => section.id == saved.id)
              ? [
                  for (final section in sections)
                    section.id == saved.id ? saved : section,
                ]
              : [...sections, saved],
        ),
      ),
    );
  }

  Future<void> _onSectionDeleted(
    NoteTemplateSectionDeleted event,
    Emitter<NoteTemplateEditState> emit,
  ) => _send(emit, () async {
    final template = state.template;
    await _repository.deleteSection(template, event.sectionId);
    return state.copyWith(
      template: template.copyWith(
        sections: [
          for (final section in template.sections)
            if (section.id != event.sectionId) section,
        ],
      ),
    );
  });

  Future<void> _onDefault(
    NoteTemplateDefaultRequested event,
    Emitter<NoteTemplateEditState> emit,
  ) => _send(
    emit,
    () async =>
        state.copyWith(template: await _repository.setDefault(state.template)),
  );

  Future<void> _onDelete(
    NoteTemplateDeleteRequested event,
    Emitter<NoteTemplateEditState> emit,
  ) => _send(emit, () async {
    await _repository.deleteTemplate(state.template);
    return state.copyWith(deleted: true);
  });

  /// 요청 하나를 보내고 결과 상태를 낸다. 보내는 중에 들어온 요청은 버린다.
  Future<void> _send(
    Emitter<NoteTemplateEditState> emit,
    Future<NoteTemplateEditState> Function() request,
  ) async {
    if (state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      emit(await request());
    } catch (e, s) {
      Logger.e('템플릿 수정 실패', tag: 'NoteTemplates', error: e, stackTrace: s);
      emit(
        state.copyWith(
          error: e is DioException ? dioErrorMessage(e) : '요청을 처리하지 못했어요.',
        ),
      );
    }
  }
}
