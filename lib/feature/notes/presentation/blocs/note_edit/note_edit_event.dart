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
