import 'dart:async';

import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/notes/data/repositories/notes_repository.dart';
import 'package:cowork_app/feature/notes/domain/note.dart';
import 'package:cowork_app/feature/notes/presentation/blocs/notes/notes_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// 조회·삭제마다 completer 를 하나씩 내주고, 언제 어떤 결과로 끝낼지는 테스트가
/// 정한다.
class _HeldNotes extends Fake implements NotesRepository {
  final List<Completer<List<Note>>> calls = [];
  final List<Completer<void>> deletes = [];

  @override
  Future<List<Note>> fetchNotes() {
    final call = Completer<List<Note>>();
    calls.add(call);
    return call.future;
  }

  @override
  Future<void> deleteNote(Note note) {
    final call = Completer<void>();
    deletes.add(call);
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

  group('삭제', () {
    late List<String> failures;

    setUp(() {
      failures = [];
      bloc.failures.listen(failures.add);
    });

    test('서버 응답을 기다리지 않고 목록에서 먼저 뺀다', () async {
      await loaded(['하나', '둘', '셋']);

      bloc.add(NoteDeleteRequested(_note('둘')));
      await pumpEventQueue();
      expect(_titles(bloc.state), ['하나', '셋']);

      repository.deletes.last.complete();
      await pumpEventQueue();
      expect(_titles(bloc.state), ['하나', '셋']);
      expect(failures, isEmpty);
    });

    test('지우고 나면 로딩 없이 다시 읽어 서버 목록으로 맞춘다', () async {
      await loaded(['하나', '둘', '셋']);
      final readsBefore = repository.calls.length;

      bloc.add(NoteDeleteRequested(_note('둘')));
      await pumpEventQueue();
      repository.deletes.last.complete();
      await pumpEventQueue();
      expect(repository.calls.length, readsBefore + 1);

      // 그사이 다른 사람이 '넷'을 썼다.
      repository.calls.last.complete([_note('넷'), _note('하나'), _note('셋')]);
      await pumpEventQueue();

      expect(states.whereType<AsyncLoading<List<Note>>>(), isEmpty);
      expect(_titles(bloc.state), ['넷', '하나', '셋']);
    });

    test('실패하면 원래 자리에 되돌리고 실패를 한 번 알린다', () async {
      await loaded(['하나', '둘', '셋']);

      bloc.add(NoteDeleteRequested(_note('둘')));
      await pumpEventQueue();
      repository.deletes.last.completeError(Exception('네트워크'));
      await pumpEventQueue();

      expect(_titles(bloc.state), ['하나', '둘', '셋']);
      expect(failures, ['회의록을 삭제하지 못했어요.']);
    });

    test('지우기 전에 보낸 조회가 늦게 와도 지운 회의록은 다시 끼어들지 않는다', () async {
      await loaded(['하나', '둘']);

      bloc.add(const NotesRequested());
      await pumpEventQueue();
      bloc.add(NoteDeleteRequested(_note('둘')));
      await pumpEventQueue();
      // 삭제 응답보다 먼저 온다. 삭제 전에 읽은 목록이라 지운 회의록이 들어 있다.
      repository.calls.last.complete([_note('하나'), _note('둘')]);
      await pumpEventQueue();

      expect(_titles(bloc.state), ['하나']);
    });
  });
}
