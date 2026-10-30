part of 'note_template_edit_bloc.dart';

/// 템플릿 편집 화면 상태.
///
/// 고치는 요청은 바로 서버에 반영되므로, 서버가 돌려준 값으로 [template] 을 바꿔
/// 들고 있는다.
class NoteTemplateEditState extends Equatable {
  const NoteTemplateEditState({
    required this.template,
    this.busy = false,
    this.deleted = false,
    this.error,
  });

  final NoteTemplate template;

  /// 서버에 요청을 보내는 중. 그동안 버튼을 잠근다.
  final bool busy;

  /// 템플릿을 지웠다는 신호. true가 되면 화면을 닫는다.
  final bool deleted;

  /// 요청 실패 사유. 화면이 그대로 보여준다.
  final String? error;

  /// [busy]·[deleted]·[error] 는 요청마다 새로 정하므로 이어받지 않는다.
  NoteTemplateEditState copyWith({
    NoteTemplate? template,
    bool busy = false,
    bool deleted = false,
    String? error,
  }) => NoteTemplateEditState(
    template: template ?? this.template,
    busy: busy,
    deleted: deleted,
    error: error,
  );

  @override
  List<Object?> get props => [template, busy, deleted, error];
}
