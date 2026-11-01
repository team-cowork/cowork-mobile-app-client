part of 'note_edit_bloc.dart';

/// 회의록 편집 화면 상태.
///
/// 편집 중인 노트와 템플릿에서 만든 입력 칸을 들고 있다가, 저장하면 갱신된 노트로
/// 교체하고 [saved]를 세워 화면을 닫도록 뷰에 알린다.
class NoteEditState extends Equatable {
  const NoteEditState({
    required this.note,
    this.fields,
    this.templateName,
    this.templateMissing = false,
    this.saved = false,
    this.error,
  });

  final Note note;

  /// 입력 칸. 템플릿을 읽기 전에는 null 이다.
  final List<NoteSectionField>? fields;

  /// 회의록이 쓴 템플릿 이름. 메타 줄에 보인다. 못 읽었으면 null.
  final String? templateName;

  /// 템플릿을 못 읽어 본문에 있는 섹션만으로 칸을 만들었는지.
  final bool templateMissing;

  /// 저장이 끝났다는 신호. true가 되면 편집 화면을 닫고 갱신된 노트를 돌려준다.
  final bool saved;

  /// 저장하지 못한 사유. 화면이 그대로 보여준다.
  final String? error;

  /// [saved]·[error] 는 한 번만 알리는 신호라 이어받지 않는다.
  NoteEditState copyWith({Note? note, bool saved = false, String? error}) =>
      NoteEditState(
        note: note ?? this.note,
        fields: fields,
        templateName: templateName,
        templateMissing: templateMissing,
        saved: saved,
        error: error,
      );

  @override
  List<Object?> get props => [
    note,
    fields,
    templateName,
    templateMissing,
    saved,
    error,
  ];
}
