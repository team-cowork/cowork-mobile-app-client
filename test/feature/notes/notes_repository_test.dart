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
  _Server(this.responses, {this.onPost});

  final Map<String, (int, Object?)> responses;

  /// 작성 요청이 어느 채널로 갔는지 확인할 때 쓴다.
  final void Function(String path)? onPost;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path.replaceFirst('/api', '');
    if (options.method == 'POST') onPost?.call(path);
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
    expect(first.author.name, '김준혁');
    expect(first.author.date, '03.12');
    expect(first.summary, '분기 목표 정렬 및 팀별 OKR 확정.');
    expect(first.agenda, hasLength(2));
    expect(first.decisions, ['· 채팅과 이슈 트래커를 1차 MVP로 확정.']);
    expect(first.actionItems.first.done, isTrue);
    expect(first.actionItems.last.done, isFalse);
    expect(first.actionItems.last.label, '음성 채널 인원 제한 정책 확정 (서연)');
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

  test('첫 채널을 못 읽으면 읽을 수 있는 채널에 작성한다', () async {
    final posts = <String>[];
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
        '/channel/channels/10/meeting-notes': (403, null),
        '/channel/channels/11/meeting-notes': (200, const []),
        '/channel/channels/11/meeting-note-templates': (
          200,
          [
            {'id': 5, 'isActive': true},
          ],
        ),
      }, onPost: posts.add),
    );
    await repository.fetchNotes();

    await repository.createNote(title: '주간 스크럼', summary: '이번 주');

    expect(posts, ['/channel/channels/11/meeting-notes']);
  });

  test('작성한 회의록은 채널의 켜진 템플릿으로 저장된다', () async {
    final server = FakeNotesServer();
    final repository = notesRepositoryOf(server);
    await repository.fetchNotes(); // 쓸 채널을 찾는다.

    await repository.createNote(title: '주간 스크럼', summary: '이번 주 진행 상황');

    expect(server.notes.first['templateId'], 5);
    expect(jsonDecode(server.notes.first['content'] as String), {
      '요약': '이번 주 진행 상황',
    });
  });

  test('편집한 액션 아이템의 체크 상태가 저장 후 다시 읽어도 남는다', () async {
    final repository = notesRepositoryOf(FakeNotesServer());
    final note = (await repository.fetchNotes()).first;

    await repository.updateNote(
      note.copyWith(
        actionItems: [
          for (final item in note.actionItems)
            NoteActionItem(label: item.label, done: true),
        ],
      ),
    );

    final saved = (await repository.fetchNotes()).first;
    expect(saved.actionItems.map((item) => item.done), everyElement(isTrue));
    expect(saved.actionItems, hasLength(3));
  });
}
