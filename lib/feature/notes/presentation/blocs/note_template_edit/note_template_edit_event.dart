part of 'note_template_edit_bloc.dart';

sealed class NoteTemplateEditEvent extends Equatable {
  const NoteTemplateEditEvent();

  /// 이름 시트가 서버에서 고친 템플릿으로 바꾼다.
  const factory NoteTemplateEditEvent.changed(NoteTemplate template) =
      NoteTemplateChanged;

  /// 섹션 시트가 서버에 추가하거나 고친 섹션을 반영한다.
  const factory NoteTemplateEditEvent.sectionSaved(
    NoteTemplateSection section,
  ) = NoteTemplateSectionSaved;

  /// 섹션을 지운다.
  const factory NoteTemplateEditEvent.sectionDeleted(int sectionId) =
      NoteTemplateSectionDeleted;

  /// 채널의 기본 템플릿으로 둔다.
  const factory NoteTemplateEditEvent.defaultRequested() =
      NoteTemplateDefaultRequested;

  /// 템플릿을 지운다.
  const factory NoteTemplateEditEvent.deleteRequested() =
      NoteTemplateDeleteRequested;

  @override
  List<Object?> get props => [];
}

final class NoteTemplateChanged extends NoteTemplateEditEvent {
  const NoteTemplateChanged(this.template);

  final NoteTemplate template;

  @override
  List<Object?> get props => [template];
}

final class NoteTemplateSectionSaved extends NoteTemplateEditEvent {
  const NoteTemplateSectionSaved(this.section);

  final NoteTemplateSection section;

  @override
  List<Object?> get props => [section];
}

final class NoteTemplateSectionDeleted extends NoteTemplateEditEvent {
  const NoteTemplateSectionDeleted(this.sectionId);

  final int sectionId;

  @override
  List<Object?> get props => [sectionId];
}

final class NoteTemplateDefaultRequested extends NoteTemplateEditEvent {
  const NoteTemplateDefaultRequested();
}

final class NoteTemplateDeleteRequested extends NoteTemplateEditEvent {
  const NoteTemplateDeleteRequested();
}
