part of 'note_edit_bloc.dart';

sealed class NoteEditEvent extends Equatable {
  const NoteEditEvent();

  /// 회의록이 쓴 템플릿을 읽어 입력 칸을 만든다.
  const factory NoteEditEvent.started() = NoteEditStarted;

  /// 편집한 제목과 섹션(제목 → 내용)을 저장한다.
  const factory NoteEditEvent.saved({
    required String title,
    required Map<String, String> sections,
  }) = NoteEditSaved;

  /// 고른 파일을 올려 첨부 목록에 붙인다. 회의록에는 저장할 때 반영된다.
  const factory NoteEditEvent.attachmentAdded(NoteUploadFile file) =
      NoteEditAttachmentAdded;

  /// 첨부 목록에서 뺀다. 회의록에는 저장할 때 반영된다.
  const factory NoteEditEvent.attachmentRemoved(NoteAttachment attachment) =
      NoteEditAttachmentRemoved;

  @override
  List<Object?> get props => [];
}

final class NoteEditStarted extends NoteEditEvent {
  const NoteEditStarted();
}

final class NoteEditSaved extends NoteEditEvent {
  const NoteEditSaved({required this.title, required this.sections});

  final String title;

  /// 입력 칸 순서대로 담긴 섹션 제목 → 내용.
  final Map<String, String> sections;

  @override
  List<Object?> get props => [title, sections];
}

final class NoteEditAttachmentAdded extends NoteEditEvent {
  const NoteEditAttachmentAdded(this.file);

  final NoteUploadFile file;

  // 읽기 함수는 값 비교가 안 되므로 이름·크기만 비교한다.
  @override
  List<Object?> get props => [file.name, file.size];
}

final class NoteEditAttachmentRemoved extends NoteEditEvent {
  const NoteEditAttachmentRemoved(this.attachment);

  final NoteAttachment attachment;

  @override
  List<Object?> get props => [attachment];
}
