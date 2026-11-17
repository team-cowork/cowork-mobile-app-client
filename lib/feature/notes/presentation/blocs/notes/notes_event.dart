part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  /// 회의록 목록 로드를 요청한다.
  const factory NotesEvent.requested() = NotesRequested;

  /// 회의록 하나를 지운다.
  const factory NotesEvent.deleteRequested(Note note) = NoteDeleteRequested;

  @override
  List<Object?> get props => [];
}

final class NotesRequested extends NotesEvent {
  const NotesRequested();
}

final class NoteDeleteRequested extends NotesEvent {
  const NoteDeleteRequested(this.note);

  final Note note;

  @override
  List<Object?> get props => [note];
}
