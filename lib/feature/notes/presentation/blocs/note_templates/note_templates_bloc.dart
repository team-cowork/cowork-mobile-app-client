import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../channel/domain/channel.dart';
import '../../../data/notes_repository.dart';
import '../../../data/repositories/note_template_repository.dart';
import '../../../domain/note_template.dart';

part 'note_templates_event.dart';
part 'note_templates_state.dart';

/// 회의록 템플릿 목록 화면 상태를 관리하는 Bloc.
///
/// 템플릿은 채널마다 따로라서, 회의록 채널을 먼저 읽고 고른 채널의 템플릿을 읽는다.
class NoteTemplatesBloc extends Bloc<NoteTemplatesEvent, NoteTemplatesState> {
  NoteTemplatesBloc(this._notes, this._templates)
    : super(const NoteTemplatesState.initial()) {
    on<NoteTemplatesRequested>(_onLoad);
  }

  final NotesRepository _notes;
  final NoteTemplateRepository _templates;

  Future<void> _onLoad(
    NoteTemplatesRequested event,
    Emitter<NoteTemplatesState> emit,
  ) async {
    // 이미 읽은 채널로 옮길 때는 채널 목록을 그대로 두고 템플릿만 다시 읽는다.
    final loaded = switch (state) {
      AsyncSuccess(:final data)
          when data.channels.any((c) => int.parse(c.id) == event.channelId) =>
        data,
      _ => null,
    };

    if (loaded == null) {
      emit(const NoteTemplatesState.loading());
    } else if (loaded.channelId != event.channelId) {
      emit(
        NoteTemplatesState.success(
          NoteTemplatesData(
            channels: loaded.channels,
            channelId: event.channelId,
            templates: const [],
            loadingTemplates: true,
          ),
        ),
      );
    }

    try {
      final channels = loaded?.channels ?? await _notes.fetchNoteChannels();
      final ids = [for (final channel in channels) int.parse(channel.id)];
      final channelId = ids.contains(event.channelId)
          ? event.channelId
          : ids.firstOrNull;
      final templates = channelId == null
          ? const <NoteTemplate>[]
          : await _templates.fetchTemplates(channelId);
      if (_isStale(channelId)) return;
      emit(
        NoteTemplatesState.success(
          NoteTemplatesData(
            channels: channels,
            channelId: channelId,
            templates: templates,
          ),
        ),
      );
    } catch (e, s) {
      Logger.e('회의록 템플릿 조회 실패', tag: 'NoteTemplates', error: e, stackTrace: s);
      if (_isStale(event.channelId)) return;
      emit(
        NoteTemplatesState.failure(
          e is DioException ? dioErrorMessage(e) : null,
        ),
      );
    }
  }

  /// 칩은 로딩 중에도 눌리므로, 기다리는 사이 다른 채널을 골랐으면 [channelId] 의
  /// 응답은 늦게 온 것이다.
  bool _isStale(int? channelId) => switch (state) {
    AsyncSuccess(:final data) => data.channelId != channelId,
    _ => false,
  };
}
