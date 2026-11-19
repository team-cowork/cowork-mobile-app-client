import 'dart:async';

import 'package:cowork_app/feature/notes/data/repositories/note_attachment_repository.dart';
import 'package:cowork_app/feature/notes/domain/note.dart';
import 'package:cowork_app/feature/notes/domain/note_attachment.dart';
import 'package:cowork_app/feature/notes/presentation/utils/note_file_picker.dart';
import 'package:cowork_app/feature/profile/data/profile_store.dart';
import 'package:cowork_app/shared/utils/external_url.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notes_test_server.dart';

/// 바이트 [bytes] 를 담은 가짜 파일.
NoteUploadFile _file(String name, [List<int> bytes = const [1, 2, 3]]) =>
    (name: name, size: bytes.length, read: () => Stream.value(bytes));

/// 편집 화면은 섹션이 많아 기본 화면(600) 밖으로 밀리므로 세로를 넉넉히 준다.
void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// 목록 → 내 회의록(킥오프, 첨부 1개) 상세를 연다.
Future<void> _openDetail(
  WidgetTester tester,
  FakeNotesServer server, {
  NoteFilePicker? pickFile,
  UrlOpener? openUrl,
}) async {
  await tester.pumpWidget(
    notesRouterTestApp(
      notesTestRouter(pickFile: pickFile, openUrl: openUrl),
      server,
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('2026 1분기 킥오프 회의'));
  await tester.pumpAndSettle();
}

/// 상세에서 편집 화면으로 들어간다.
Future<void> _openEditor(
  WidgetTester tester,
  FakeNotesServer server, {
  required NoteFilePicker pickFile,
}) async {
  await _openDetail(tester, server, pickFile: pickFile);
  await tester.tap(find.byIcon(Icons.edit_outlined));
  await tester.pumpAndSettle();
}

Iterable<String> _paths(FakeNotesServer server, String method) =>
    server.requests.where((r) => r.$1 == method).map((r) => r.$2);

void main() {
  setUp(() => ProfileStore.instance.currentUserId = 1);

  group('저장소', () {
    test('MIME 은 이름으로 정하고, 서버와 이름이 다른 형식은 서버 이름으로 보낸다', () {
      expect(
        NoteAttachmentRepository.contentTypeOf('자료.pdf'),
        'application/pdf',
      );
      expect(NoteAttachmentRepository.contentTypeOf('사진.JPG'), 'image/jpeg');
      // mime 패키지는 audio/x-wav, 서버는 audio/wav 로 부른다.
      expect(NoteAttachmentRepository.contentTypeOf('녹음.wav'), 'audio/wav');
      // 모르는 형식도 서버에 묻는다.
      expect(
        NoteAttachmentRepository.contentTypeOf('확장자없음'),
        'application/octet-stream',
      );
    });

    test('주소 발급 → 스토리지 PUT → 확인 순서로 올리고 확정 키를 돌려준다', () async {
      final server = FakeNotesServer();
      final progress = <double>[];

      final attachment = await noteAttachmentRepositoryOf(
        server,
      ).upload(10, _file('회의자료.pdf', [7, 8, 9, 10]), onProgress: progress.add);

      expect(server.requests.map((r) => '${r.$1} ${r.$2}').toList(), [
        'POST /chat/chat/channels/10/files/presigned-url',
        startsWith('PUT /storage/cowork/chat-uploads/10/1/'),
        'POST /chat/chat/channels/10/files/confirm',
      ]);
      // 서버는 발급 때 신고한 형식·크기를 실제 파일과 비교한다.
      expect(server.requests.first.$3, {
        'filename': '회의자료.pdf',
        'contentType': 'application/pdf',
        'size': 4,
      });
      final (headers, bytes) = server.stored.single;
      expect(bytes, [7, 8, 9, 10]);
      expect(headers['content-type'], 'application/pdf');
      expect(headers['content-length'], 4);
      expect(progress.last, 1.0);
      // 확인에는 임시 키를 보내고, 회의록에는 확정 키를 쓴다.
      expect(
        server.requests.last.$3['objectKey'],
        startsWith('chat-uploads/10/1/'),
      );
      expect(attachment.objectKey, startsWith('chat-files/10/1/'));
      expect(attachment.name, '회의자료.pdf');
    });

    test('다운로드 주소는 회의록 경로에 objectKey 를 실어 받는다', () async {
      final server = FakeNotesServer();
      const note = Note(
        id: 1,
        channelId: 10,
        title: '',
        tags: [],
        author: NoteAuthor(authorId: 1, name: '', initial: '', date: ''),
      );

      final url = await noteAttachmentRepositoryOf(server).fetchDownloadUrl(
        note,
        const NoteAttachment(
          objectKey: 'chat-files/10/1/kickoff.pdf',
          name: '킥오프 자료.pdf',
        ),
      );

      expect(url, 'https://files.test/chat-files/10/1/kickoff.pdf');
      expect(_paths(server, 'GET'), [
        '/channel/channels/10/meeting-notes/1/attachments/download-url',
      ]);
    });

    test('새 회의록을 만들 때 첨부 목록을 함께 보낸다', () async {
      final server = FakeNotesServer();
      const note = Note(
        id: 0,
        channelId: 10,
        templateId: 5,
        title: '새 회의',
        tags: [],
        author: NoteAuthor(authorId: 1, name: '', initial: '', date: ''),
        attachments: [
          NoteAttachment(objectKey: 'chat-files/10/1/a.png', name: '화이트보드.png'),
        ],
      );

      final created = await notesRepositoryOf(server).createNote(note);

      expect(server.requests.first.$3['attachments'], [
        {'objectKey': 'chat-files/10/1/a.png', 'name': '화이트보드.png'},
      ]);
      expect(created.attachments, note.attachments);
    });
  });

  group('편집 화면', () {
    testWidgets('파일을 고르면 바로 올리고, 저장하면 기존 첨부와 함께 보낸다', (tester) async {
      _tall(tester);
      final server = FakeNotesServer();
      await _openEditor(
        tester,
        server,
        pickFile: () async => _file('회의 메모.txt'),
      );
      expect(find.text('킥오프 자료.pdf'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();
      expect(find.text('회의 메모.txt'), findsOneWidget);
      expect(_paths(server, 'PATCH'), isEmpty); // 저장 전에는 회의록에 안 붙는다.

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      final sent = server.requests.lastWhere((r) => r.$1 == 'PATCH').$3;
      final attachments = (sent['attachments'] as List).cast<Map>();
      expect(attachments.map((a) => a['name']), ['킥오프 자료.pdf', '회의 메모.txt']);
      expect(attachments.last['objectKey'], startsWith('chat-files/10/1/'));
      // 상세로 돌아오면 새 첨부가 보인다.
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.text('회의 메모.txt'), findsOneWidget);
    });

    testWidgets('올리는 동안에는 진행률을 보이고 저장을 막는다', (tester) async {
      _tall(tester);
      final server = FakeNotesServer()..holdUpload = Completer();
      await _openEditor(tester, server, pickFile: () async => _file('녹음.m4a'));

      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();
      expect(find.byType(CoworkFileUploadProgress), findsOneWidget);

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect(find.text('파일을 다 올린 뒤에 저장해 주세요.'), findsOneWidget);
      expect(_paths(server, 'PATCH'), isEmpty);

      server.holdUpload!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CoworkFileUploadProgress), findsNothing);
      expect(find.text('녹음.m4a'), findsOneWidget);
    });

    testWidgets('첨부를 빼고 저장하면 빈 목록을 보내 회의록에서 푼다', (tester) async {
      _tall(tester);
      final server = FakeNotesServer();
      await _openEditor(tester, server, pickFile: () async => null);

      await tester.tap(find.bySemanticsLabel('킥오프 자료.pdf 빼기'));
      await tester.pumpAndSettle();
      expect(find.text('킥오프 자료.pdf'), findsNothing);

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect(
        server.requests.lastWhere((r) => r.$1 == 'PATCH').$3['attachments'],
        isEmpty,
      );
    });

    testWidgets('서버가 받지 않는 형식이면 서버 사유를 알리고 파일은 올리지 않는다', (tester) async {
      _tall(tester);
      final server = FakeNotesServer();
      await _openEditor(
        tester,
        server,
        pickFile: () async => _file('계약서.docx'),
      );

      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();

      // 형식은 앱이 거르지 않고 서버에 묻는다. 서버는 주소를 주지 않고 거절한다.
      expect(_paths(server, 'POST'), [
        '/chat/chat/channels/10/files/presigned-url',
      ]);
      expect(find.textContaining('허용되지 않은 파일 형식'), findsOneWidget);
      expect(server.stored, isEmpty);
      expect(find.byType(CoworkFileUploadProgress), findsNothing);
    });

    testWidgets('20개가 붙어 있으면 더 고른 파일은 올리지 않고 알린다', (tester) async {
      _tall(tester);
      final server = FakeNotesServer();
      server.notes.first['attachments'] = [
        for (var i = 0; i < 20; i++)
          {'objectKey': 'chat-files/10/1/f$i.png', 'name': '사진$i.png'},
      ];
      await _openEditor(tester, server, pickFile: () async => _file('하나더.png'));

      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();

      expect(find.text('첨부파일은 20개까지 붙일 수 있어요.'), findsOneWidget);
      expect(_paths(server, 'POST'), isEmpty);
    });

    testWidgets('올리는 중인 파일도 20개 제한에 센다', (tester) async {
      _tall(tester);
      final server = FakeNotesServer()..holdUpload = Completer();
      server.notes.first['attachments'] = [
        for (var i = 0; i < 19; i++)
          {'objectKey': 'chat-files/10/1/f$i.png', 'name': '사진$i.png'},
      ];
      await _openEditor(
        tester,
        server,
        pickFile: () async => _file('스무번째.png'),
      );

      // 19개 + 올리는 중 1개 = 20개라 다음 파일은 받지 않는다.
      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();

      expect(find.text('첨부파일은 20개까지 붙일 수 있어요.'), findsOneWidget);
      expect(_paths(server, 'POST'), [
        '/chat/chat/channels/10/files/presigned-url',
      ]);

      server.holdUpload!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('크기가 0 인 파일은 올리지 않고 알린다', (tester) async {
      _tall(tester);
      final server = FakeNotesServer();
      await _openEditor(
        tester,
        server,
        pickFile: () async => _file('빈 파일.txt', const []),
      );

      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();

      expect(find.text('빈 파일은 붙일 수 없어요.'), findsOneWidget);
      expect(_paths(server, 'POST'), isEmpty);
    });

    testWidgets('서버가 업로드를 거절하면 사유를 알리고 진행 카드를 지운다', (tester) async {
      _tall(tester);
      final server = FakeNotesServer()
        ..failUpload = (413, '파일 크기가 허용 한도를 초과했습니다');
      await _openEditor(tester, server, pickFile: () async => _file('영상.mp4'));

      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();

      expect(find.textContaining('허용 한도를 초과'), findsOneWidget);
      expect(find.byType(CoworkFileUploadProgress), findsNothing);
      expect(find.text('영상.mp4'), findsNothing);
    });

    testWidgets('파일을 고르지 못하면 알린다', (tester) async {
      _tall(tester);
      final server = FakeNotesServer();
      await _openEditor(
        tester,
        server,
        pickFile: () async => throw StateError('크기를 알 수 없다'),
      );

      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();

      expect(find.text('파일을 열지 못했어요.'), findsOneWidget);
      expect(_paths(server, 'POST'), isEmpty);
    });
  });

  group('상세 화면', () {
    testWidgets('첨부를 누르면 임시 주소를 받아 연다', (tester) async {
      _tall(tester);
      final opened = <Uri>[];
      await _openDetail(
        tester,
        FakeNotesServer(),
        openUrl: (url) async {
          opened.add(url);
          return true;
        },
      );

      await tester.tap(find.text('킥오프 자료.pdf'));
      await tester.pumpAndSettle();

      expect(opened, [
        Uri.parse('https://files.test/chat-files/10/1/kickoff.pdf'),
      ]);
    });

    testWidgets('열 앱이 없으면 알린다', (tester) async {
      _tall(tester);
      await _openDetail(tester, FakeNotesServer(), openUrl: (_) async => false);

      await tester.tap(find.text('킥오프 자료.pdf'));
      await tester.pumpAndSettle();

      expect(find.text('파일을 열 수 있는 앱이 없어요.'), findsOneWidget);
    });
  });
}
