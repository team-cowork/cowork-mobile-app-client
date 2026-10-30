import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/notes/domain/note.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notes_test_server.dart';

/// 경로마다 상태 코드와 본문을 정해 두는 어댑터. 못 읽는 채널을 흉내낼 때 쓴다.
///
/// 경로는 게이트웨이처럼 서비스 prefix 를 붙여 적는다(`/channel/channels/...`).
class _Server implements HttpClientAdapter {
  _Server(this.responses);

  final Map<String, (int, Object?)> responses;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path.replaceFirst('/api', '');
    final (status, data) = responses[path] ?? (404, null);
    return ResponseBody.fromString(
      jsonEncode({'status': 'OK', 'code': status, 'data': data}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('회의록을 최신순으로 모으고 섹션·작성자를 화면 모델로 옮긴다', () async {
    final notes = await notesRepositoryOf(FakeNotesServer()).fetchNotes();

    expect(notes.map((note) => note.title), [
      '2026 1분기 킥오프 회의',
      '디자인 시스템 리뷰',
      '스프린트 회고 #3',
    ]);

    final first = notes.first;
    expect(first.channelId, 10);
    expect(first.templateId, 5);
    expect(first.author.name, '김준혁');
    expect(first.author.date, '03.12');
    expect(first.summary, '분기 목표 정렬 및 팀별 OKR 확정.');
    expect(first.sections.keys, ['요약', '참석자', '안건', '결정 사항', '액션 아이템']);
  });

  test('못 읽는 채널이 있어도 나머지 채널의 회의록은 보여준다', () async {
    final repository = notesRepositoryOf(
      _Server({
        '/team/teams': (
          200,
          [
            {'id': 1},
          ],
        ),
        '/channel/teams/1/channels': (
          200,
          [
            {'id': 10},
            {'id': 11},
          ],
        ),
        '/channel/channels/10/meeting-notes': (
          200,
          [
            {
              'id': 1,
              'channelId': 10,
              'title': '읽을 수 있는 채널',
              'content': '{}',
              'createdBy': 1,
              'createdAt': '2026-03-12T09:00:00Z',
            },
          ],
        ),
        '/channel/channels/11/meeting-notes': (403, null),
        '/user/users/1': (200, {'id': 1, 'name': '김준혁'}),
      }),
    );

    expect((await repository.fetchNotes()).map((note) => note.title), [
      '읽을 수 있는 채널',
    ]);
  });

  test('못 읽는 채널 말고 다른 실패는 그대로 던진다', () async {
    final repository = notesRepositoryOf(
      _Server({
        '/team/teams': (
          200,
          [
            {'id': 1},
          ],
        ),
        '/channel/teams/1/channels': (
          200,
          [
            {'id': 10},
          ],
        ),
        '/channel/channels/10/meeting-notes': (500, null),
      }),
    );

    expect(repository.fetchNotes(), throwsA(isA<DioException>()));
  });

  test('회의록 채널만 골라 준다', () async {
    final channels = await notesRepositoryOf(
      FakeNotesServer(),
    ).fetchNoteChannels();

    expect(channels.map((channel) => channel.name), ['회의록', '주간 회의']);
  });

  test('처음 저장한 회의록을 본문까지 채워 만들고, 서버가 정한 id 를 돌려준다', () async {
    final server = FakeNotesServer();

    final note = await notesRepositoryOf(server).createNote(
      const Note(
        id: 0,
        channelId: 10,
        templateId: 6,
        title: '주간 스크럼',
        tags: [],
        author: NoteAuthor(authorId: 1, name: '', initial: '', date: ''),
        sections: {'Keep': '배포 자동화'},
      ),
    );

    final saved = server.notes.first;
    expect(saved['templateId'], 6);
    expect(jsonDecode(saved['content'] as String), {'Keep': '배포 자동화'});
    expect(note.id, saved['id']);
    expect(note.channelId, 10);
    expect(note.templateId, 6);
    expect(note.title, '주간 스크럼');
    expect(note.author.name, '김준혁');
  });

  test('저장한 섹션을 보낸 순서 그대로 다시 읽는다', () async {
    final repository = notesRepositoryOf(FakeNotesServer());
    final note = (await repository.fetchNotes()).first;

    await repository.updateNote(
      note.copyWith(
        title: '수정한 제목',
        sections: {'참석자': '김준혁', '안건': '- [x] 끝난 일', '메모': '템플릿 밖'},
      ),
    );

    final saved = (await repository.fetchNotes()).first;
    expect(saved.title, '수정한 제목');
    expect(saved.sections.keys, ['참석자', '안건', '메모']);
    expect(saved.sections['안건'], '- [x] 끝난 일');
  });
}
