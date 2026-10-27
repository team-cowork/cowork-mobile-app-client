import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/notes_repository.dart';
import '../../../domain/note.dart';

part 'notes_event.dart';
part 'notes_state.dart';

/// 회의록 화면 상태를 관리하는 Bloc.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc(this._repository) : super(const NotesState.initial()) {
    on<NotesRequested>(_onLoad);
  }

  final NotesRepository _repository;

  Future<void> _onLoad(NotesRequested event, Emitter<NotesState> emit) async {
    emit(const NotesState.loading());
    try {
      emit(NotesState.success(await _repository.fetchNotes()));
    } catch (e, s) {
      Logger.e('회의록 조회 실패', tag: 'Notes', error: e, stackTrace: s);
      emit(NotesState.failure(e is DioException ? dioErrorMessage(e) : null));
    }
  }
}
