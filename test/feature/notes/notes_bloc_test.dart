import 'dart:async';

import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/notes/data/repositories/notes_repository.dart';
import 'package:cowork_app/feature/notes/domain/note.dart';
import 'package:cowork_app/feature/notes/presentation/blocs/notes/notes_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// 조회마다 completer 를 하나씩 내주고, 언제 어떤 결과로 끝낼지는 테스트가 정한다.
class _HeldNotes extends Fake implements NotesRepository {
  final List<Completer<List<Note>>> calls = [];

  @override
  Future<List<Note>> fetchNotes() {
    final call = Completer<List<Note>>();
    calls.add(call);
    return call.future;
  }
}

Note _note(String title) => Note(
  id: title.hashCode,
  channelId: 10,
  templateId: 1,
  title: title,
  tags: const [],
  author: const NoteAuthor(authorId: 1, name: '', initial: '', date: ''),
);

List<String> _titles(NotesState state) => switch (state) {
  AsyncSuccess(:final data) => [for (final note in data) note.title],
  _ => const [],
};

void main() {
  late _HeldNotes repository;
  late NotesBloc bloc;
  late List<NotesState> states;

  setUp(() {
    repository = _HeldNotes();
    bloc = NotesBloc(repository);
    states = [];
    bloc.stream.listen(states.add);
  });

  tearDown(() => bloc.close());

  /// 처음 읽어 목록을 띄워 둔다.
  Future<void> loaded(List<String> titles) async {
    bloc.add(const NotesRequested());
    await pumpEventQueue();
    repository.calls.last.complete([for (final t in titles) _note(t)]);
    await pumpEventQueue();
    states.clear();
  }

  test('목록이 있으면 다시 읽는 동안 로딩으로 바꾸지 않는다', () async {
    await loaded(['처음']);

    bloc.add(const NotesRequested());
    await pumpEventQueue();
    expect(states, isEmpty);

    repository.calls.last.complete([_note('갱신')]);
    await pumpEventQueue();
    expect(states.map(_titles), [
      ['갱신'],
    ]);
  });

  test('늦게 온 이전 조회 응답은 새 목록을 덮지 않는다', () async {
    await loaded(['처음']);

    bloc
      ..add(const NotesRequested())
      ..add(const NotesRequested());
    await pumpEventQueue();
    final [older, newer] = repository.calls.sublist(1);

    newer.complete([_note('새 목록')]);
    await pumpEventQueue();
    older.complete([_note('옛 목록')]);
    await pumpEventQueue();

    expect(_titles(bloc.state), ['새 목록']);
  });

  test('다시 읽기에 실패해도 보던 목록은 그대로 둔다', () async {
    await loaded(['처음']);

    bloc.add(const NotesRequested());
    await pumpEventQueue();
    repository.calls.last.completeError(Exception('네트워크'));
    await pumpEventQueue();

    expect(states, isEmpty);
    expect(_titles(bloc.state), ['처음']);
  });

  test('목록이 없을 때 실패하면 오류 화면으로 간다', () async {
    bloc.add(const NotesRequested());
    await pumpEventQueue();
    expect(bloc.state, isA<AsyncLoading<List<Note>>>());

    repository.calls.last.completeError(Exception('네트워크'));
    await pumpEventQueue();
    expect(bloc.state, isA<AsyncFailure<List<Note>>>());
  });
}
