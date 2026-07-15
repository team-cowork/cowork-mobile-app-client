part of 'notes_bloc.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  const factory NotesState.initial() = NotesInitial;
  const factory NotesState.loading() = NotesLoading;
  const factory NotesState.success(List<Note> notes) = NotesSuccess;
  const factory NotesState.failure() = NotesFailure;

  @override
  List<Object?> get props => [];
}

final class NotesInitial extends NotesState {
  const NotesInitial();
}

final class NotesLoading extends NotesState {
  const NotesLoading();
}

final class NotesSuccess extends NotesState {
  const NotesSuccess(this.notes);

  final List<Note> notes;

  @override
  List<Object?> get props => [notes];
}

final class NotesFailure extends NotesState {
  const NotesFailure();
}
