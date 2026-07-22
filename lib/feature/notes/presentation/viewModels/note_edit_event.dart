part of 'note_edit_bloc.dart';

sealed class NoteEditEvent extends Equatable {
  const NoteEditEvent();

  /// 편집한 내용을 저장한다. 제목/요약/안건/결정 사항/액션 아이템을 갱신한다.
  const factory NoteEditEvent.saved({
    required String title,
    required String summary,
    required List<String> agenda,
    required List<String> decisions,
    required List<NoteActionItem> actionItems,
  }) = NoteEditSaved;

  @override
  List<Object?> get props => [];
}

final class NoteEditSaved extends NoteEditEvent {
  const NoteEditSaved({
    required this.title,
    required this.summary,
    required this.agenda,
    required this.decisions,
    required this.actionItems,
  });

  final String title;
  final String summary;
  final List<String> agenda;
  final List<String> decisions;
  final List<NoteActionItem> actionItems;

  @override
  List<Object?> get props => [title, summary, agenda, decisions, actionItems];
}
