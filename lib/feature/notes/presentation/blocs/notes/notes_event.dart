part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  /// 회의록 목록 로드를 요청한다.
  const factory NotesEvent.requested() = NotesRequested;

  @override
  List<Object?> get props => [];
}

final class NotesRequested extends NotesEvent {
  const NotesRequested();
}
