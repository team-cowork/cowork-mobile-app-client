part of 'note_edit_bloc.dart';

/// 회의록 편집 화면 상태.
///
/// 편집 중인 노트와 템플릿에서 만든 입력 칸을 들고 있다가, 저장하면 갱신된 노트로
/// 교체하고 [saved]를 세워 화면을 닫도록 뷰에 알린다. 다 올린 첨부는 [note] 의
/// `attachments` 에 바로 붙이고, 올리는 중인 파일은 [uploads] 에 따로 둔다.
class NoteEditState extends Equatable {
  const NoteEditState({
    required this.note,
    this.fields,
    this.templateName,
    this.templateMissing = false,
    this.uploads = const [],
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

  /// 올리는 중인 파일. 고른 순서대로다.
  final List<NoteUpload> uploads;

  /// 저장이 끝났다는 신호. true가 되면 편집 화면을 닫고 갱신된 노트를 돌려준다.
  final bool saved;

  /// 저장하거나 파일을 올리지 못한 사유. 화면이 그대로 보여준다.
  final String? error;

  /// [saved]·[error] 는 한 번만 알리는 신호라 이어받지 않는다.
  NoteEditState copyWith({
    Note? note,
    List<NoteUpload>? uploads,
    bool saved = false,
    String? error,
  }) => NoteEditState(
    note: note ?? this.note,
    fields: fields,
    templateName: templateName,
    templateMissing: templateMissing,
    uploads: uploads ?? this.uploads,
    saved: saved,
    error: error,
  );

  @override
  List<Object?> get props => [
    note,
    fields,
    templateName,
    templateMissing,
    uploads,
    saved,
    error,
  ];
}

/// 올리는 중인 파일 하나.
final class NoteUpload extends Equatable {
  const NoteUpload({required this.id, required this.name, this.progress = 0});

  /// 같은 이름의 파일을 둘 골라도 구분하려고 Bloc 이 매기는 번호.
  final int id;

  final String name;

  /// 스토리지로 보낸 비율(0~1). 확인 요청이 남아 있어 1 이어도 끝난 게 아니다.
  final double progress;

  NoteUpload copyWith({double? progress}) =>
      NoteUpload(id: id, name: name, progress: progress ?? this.progress);

  @override
  List<Object?> get props => [id, name, progress];
}
