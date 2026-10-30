part of 'note_templates_bloc.dart';

/// 회의록 템플릿 목록 상태. 성공 시 채널과 고른 채널의 템플릿을 담는다.
typedef NoteTemplatesState = AsyncState<NoteTemplatesData>;

/// 템플릿 목록 화면이 그리는 데이터.
class NoteTemplatesData extends Equatable {
  const NoteTemplatesData({
    required this.channels,
    required this.channelId,
    required this.templates,
    this.loadingTemplates = false,
  });

  /// 내 회의록 채널.
  final List<Channel> channels;

  /// 고른 채널. 회의록 채널이 없으면 null.
  final int? channelId;

  /// 고른 채널의 템플릿.
  final List<NoteTemplate> templates;

  /// 채널을 바꿔 템플릿을 읽는 중인지. 채널 칩은 그대로 두고 템플릿 영역만 로딩을
  /// 보여준다.
  final bool loadingTemplates;

  @override
  List<Object?> get props => [channels, channelId, templates, loadingTemplates];
}
