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
    emit(const NoteTemplatesState.loading());
    try {
      final channels = await _notes.fetchNoteChannels();
      final ids = [for (final channel in channels) int.parse(channel.id)];
      final channelId = ids.contains(event.channelId)
          ? event.channelId
          : ids.firstOrNull;
      emit(
        NoteTemplatesState.success(
          NoteTemplatesData(
            channels: channels,
            channelId: channelId,
            templates: channelId == null
                ? const []
                : await _templates.fetchTemplates(channelId),
          ),
        ),
      );
    } catch (e, s) {
      Logger.e('회의록 템플릿 조회 실패', tag: 'NoteTemplates', error: e, stackTrace: s);
      emit(
        NoteTemplatesState.failure(
          e is DioException ? dioErrorMessage(e) : null,
        ),
      );
    }
  }
}
