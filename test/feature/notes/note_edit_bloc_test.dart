import 'package:cowork_app/feature/notes/presentation/blocs/note_edit/note_edit_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notes_test_server.dart';

void main() {
  test('저장하는 중에 또 저장해도 서버에는 한 번만 보낸다', () async {
    final server = FakeNotesServer();
    final note = (await notesRepositoryOf(server).fetchNotes()).first;
    final bloc = NoteEditBloc(
      note,
      notesRepositoryOf(server),
      noteTemplateRepositoryOf(server),
      noteAttachmentRepositoryOf(server),
    );
    addTearDown(bloc.close);
    server.requests.clear();

    bloc
      ..add(const NoteEditEvent.saved(title: '고친 제목', sections: {}))
      ..add(const NoteEditEvent.saved(title: '고친 제목', sections: {}));
    await bloc.stream.firstWhere((s) => s.saved);
    await pumpEventQueue();

    expect(server.requests.where((r) => r.$1 == 'PATCH'), hasLength(1));
  });
}
