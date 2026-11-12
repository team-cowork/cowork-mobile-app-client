import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/repositories/notes_repository.dart';
import '../../../domain/note.dart';

part 'notes_event.dart';
part 'notes_state.dart';

/// 회의록 화면 상태를 관리하는 Bloc.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc(this._repository) : super(const NotesState.initial()) {
    on<NotesRequested>(_onLoad);
    on<NoteDeleteRequested>(_onDelete);
  }

  final NotesRepository _repository;

  final _failures = StreamController<String>.broadcast();

  /// 목록은 그대로 두고 한 번만 알릴 실패 문구. 화면이 SnackBar 로 띄운다.
  ///
  /// [NotesState] 는 목록 하나만 담으므로, 목록이 성공인 채로 실패를 알릴 자리가
  /// 없어 따로 흘린다.
  Stream<String> get failures => _failures.stream;

  /// 지우는 중이거나 지운 회의록 id. 조회 결과에서도 뺀다.
  ///
  /// 지우기 전에 보낸 조회가 늦게 오면 지운 회의록이 다시 끼어들기 때문이다.
  final Set<int> _deleted = {};

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
      if (request != _latest) return;
      emit(
        NotesState.success([
          for (final note in notes)
            if (!_deleted.contains(note.id)) note,
        ]),
      );
    } catch (e, s) {
      Logger.e('회의록 조회 실패', tag: 'Notes', error: e, stackTrace: s);
      if (request != _latest || refreshing) return;
      emit(NotesState.failure(e is DioException ? dioErrorMessage(e) : null));
    }
  }

  /// 목록에서 먼저 빼고 서버에 지운다(낙관적 업데이트). 실패하면 원래 자리에
  /// 되돌리고 [failures] 로 알린다.
  ///
  /// 목록 화면의 `Dismissible` 은 밀어낸 카드가 곧바로 목록에서 빠져야 하므로,
  /// 응답을 기다리지 않고 먼저 뺀다.
  ///
  /// 지우고 나면 목록을 다시 읽어 서버와 맞춘다. 회의록은 실시간으로 갱신되지
  /// 않아 그사이 다른 사람이 바꾼 것을 여기서 받아 온다. 목록이 있으니 로딩으로
  /// 바꾸지 않고 조용히 바꿔 끼운다([_onLoad]).
  Future<void> _onDelete(
    NoteDeleteRequested event,
    Emitter<NotesState> emit,
  ) async {
    final note = event.note;
    // 지우는 카드는 목록에서만 밀 수 있으므로 목록이 없으면 할 일이 없다.
    if (state is! AsyncSuccess<List<Note>>) return;
    final before = (state as AsyncSuccess<List<Note>>).data;
    final index = before.indexWhere((it) => it.id == note.id);
    if (index < 0) return;

    _deleted.add(note.id);
    emit(NotesState.success([...before]..removeAt(index)));
    try {
      await _repository.deleteNote(note);
      // 기다리는 사이 화면을 떠났으면 닫힌 Bloc 이라 이벤트를 받을 수 없다.
      if (!isClosed) add(const NotesRequested());
    } catch (e, s) {
      Logger.e('회의록 삭제 실패', tag: 'Notes', error: e, stackTrace: s);
      _deleted.remove(note.id);
      // 기다리는 사이 목록이 바뀌었을 수 있으니(다시 읽기, 다른 삭제) 지금 목록에
      // 이 회의록만 되돌린다. 자리가 줄었으면 끝에 둔다.
      if (state case AsyncSuccess(
        :final data,
      ) when !data.any((it) => it.id == note.id)) {
        emit(
          NotesState.success(
            [...data]..insert(index.clamp(0, data.length), note),
          ),
        );
      }
      _failures.add(
        (e is DioException ? dioErrorMessage(e) : null) ?? '회의록을 삭제하지 못했어요.',
      );
    }
  }

  @override
  Future<void> close() async {
    await _failures.close();
    return super.close();
  }
}
