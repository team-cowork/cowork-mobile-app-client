part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  /// 회의록 목록 로드를 요청한다.
  const factory NotesEvent.requested() = NotesRequested;

  /// 새 회의록을 추가한다.
  const factory NotesEvent.added({
    required String title,
    required String content,
    required String template,
  }) = NoteAdded;

  @override
  List<Object?> get props => [];
}

final class NotesRequested extends NotesEvent {
  const NotesRequested();
}

final class NoteAdded extends NotesEvent {
  const NoteAdded({
    required this.title,
    required this.content,
    required this.template,
  });

  final String title;
  final String content;

  /// 선택한 템플릿 라벨. 카드 태그로 노출된다.
  final String template;

  @override
  List<Object?> get props => [title, content, template];
}

sealed class NewNoteEvent extends Equatable {
  const NewNoteEvent();

  /// 새 노트 시트의 입력값이 바뀌었다. 전달한 항목만 갱신한다.
  const factory NewNoteEvent.changed({
    String? title,
    String? content,
    int? template,
  }) = NewNoteChanged;

  @override
  List<Object?> get props => [];
}

final class NewNoteChanged extends NewNoteEvent {
  const NewNoteChanged({this.title, this.content, this.template});

  final String? title;
  final String? content;
  final int? template;

  @override
  List<Object?> get props => [title, content, template];
}
