part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  /// 회의록 목록 로드를 요청한다.
  const factory NotesEvent.requested({Completer<void>? done}) = NotesRequested;

  /// 회의록 하나를 지운다.
  const factory NotesEvent.deleteRequested(Note note) = NoteDeleteRequested;

  @override
  List<Object?> get props => [];
}

final class NotesRequested extends NotesEvent {
  const NotesRequested({this.done});

  /// 조회가 끝나면 성공·실패와 상관없이 완료된다. 당겨서 새로고침이 인디케이터를
  /// 언제 멈출지 알려고 쓴다.
  ///
  /// 다시 읽기는 실패하거나 같은 목록을 받으면 상태가 바뀌지 않아, 상태 스트림만
  /// 보고는 끝났는지 알 수 없다.
  final Completer<void>? done;
}

final class NoteDeleteRequested extends NotesEvent {
  const NoteDeleteRequested(this.note);

  final Note note;

  @override
  List<Object?> get props => [note];
}
