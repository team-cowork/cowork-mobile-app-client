part of 'note_templates_bloc.dart';

sealed class NoteTemplatesEvent extends Equatable {
  const NoteTemplatesEvent();

  /// 회의록 채널과 그중 [channelId] 채널의 템플릿을 읽는다. 채널을 바꾸거나 고친
  /// 템플릿을 다시 읽을 때도 쓴다.
  const factory NoteTemplatesEvent.requested({int? channelId}) =
      NoteTemplatesRequested;

  @override
  List<Object?> get props => [];
}

final class NoteTemplatesRequested extends NoteTemplatesEvent {
  const NoteTemplatesRequested({this.channelId});

  /// 고를 채널. 없거나 내 회의록 채널이 아니면 첫 채널을 고른다.
  final int? channelId;

  @override
  List<Object?> get props => [channelId];
}
