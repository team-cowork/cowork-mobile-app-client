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

  /// 마지막으로 보낸 조회 번호. 요청이 겹치면 이 번호의 응답만 화면에 낸다.
  ///
  /// 이벤트는 동시에 처리되므로, 먼저 보낸 조회가 늦게 오면 새 목록을 옛 목록으로
  /// 덮을 수 있다.
  int _latest = 0;

  /// 이미 목록이 있으면 로딩으로 바꾸지 않고 조용히 바꿔 끼운다. 스피너로 바꾸면
  /// 목록이 통째로 다시 그려져 스크롤 위치를 잃는다. 같은 이유로 다시 읽기에
  /// 실패해도 보던 목록은 그대로 둔다.
  Future<void> _onLoad(NotesRequested event, Emitter<NotesState> emit) async {
    final request = ++_latest;
    final refreshing = state is AsyncSuccess<List<Note>>;
    if (!refreshing) emit(const NotesState.loading());
    try {
      final notes = await _repository.fetchNotes();
      if (request == _latest) emit(NotesState.success(notes));
    } catch (e, s) {
      Logger.e('회의록 조회 실패', tag: 'Notes', error: e, stackTrace: s);
      if (request != _latest || refreshing) return;
      emit(NotesState.failure(e is DioException ? dioErrorMessage(e) : null));
    }
  }
}
