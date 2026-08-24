part of 'note_edit_bloc.dart';

/// 회의록 편집 화면 상태.
///
/// 편집 중인 노트를 들고 있다가, 저장하면 갱신된 노트로 교체하고 [saved]를 세워
/// 화면을 닫도록 뷰에 알린다.
class NoteEditState extends Equatable {
  const NoteEditState({required this.note, this.saved = false});

  final Note note;

  /// 저장이 끝났다는 신호. true가 되면 편집 화면을 닫고 갱신된 노트를 돌려준다.
  final bool saved;

  @override
  List<Object?> get props => [note, saved];
}
