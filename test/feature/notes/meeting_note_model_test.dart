import 'package:cowork_app/feature/notes/data/model/requests/create_meeting_note_request.dart';
import 'package:cowork_app/feature/notes/data/model/requests/meeting_note_attachment_request.dart';
import 'package:cowork_app/feature/notes/data/model/requests/update_meeting_note_request.dart';
import 'package:cowork_app/feature/notes/data/model/responses/meeting_note_response.dart';
import 'package:cowork_app/feature/notes/domain/note.dart';
import 'package:cowork_app/feature/notes/domain/note_attachment.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, String> _sectionsOf(Object? content) =>
    MeetingNoteResponse.fromJson({'content': content}).sections;

void main() {
  group('응답 content', () {
    test('JSON 문자열을 섹션 맵으로 푼다', () {
      expect(_sectionsOf('{"안건":"1. 배포","결정 사항":"· 금요일"}'), {
        '안건': '1. 배포',
        '결정 사항': '· 금요일',
      });
    });

    test('객체로 내려와도 그대로 받는다', () {
      expect(_sectionsOf({'안건': '1. 배포', '횟수': 2}), {'안건': '1. 배포', '횟수': '2'});
    });

    test('배열·객체 값은 JSON 모양 그대로 두고, null 은 빈 칸으로 본다', () {
      expect(_sectionsOf('{"참석자":["김준혁","도윤"],"메타":{"장소":"3층"},"메모":null}'), {
        '참석자': '["김준혁","도윤"]',
        '메타': '{"장소":"3층"}',
        '메모': '',
      });
    });

    test('JSON 이 아니면 통째로 요약 한 섹션으로 본다', () {
      expect(_sectionsOf('그냥 메모'), {'요약': '그냥 메모'});
    });

    test('비었거나 없으면 섹션이 없다', () {
      expect(_sectionsOf(''), isEmpty);
      expect(_sectionsOf(null), isEmpty);
    });
  });

  test('필드가 빠져도 기본값으로 읽고, createdAt 을 못 읽으면 맨 뒤로 보낸다', () {
    final note = MeetingNoteResponse.fromJson({'createdAt': '깨진 날짜'});

    expect(note.id, 0);
    expect(note.title, '');
    expect(note.createdBy, 0);
    expect(note.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('오프셋 없는 createdAt 은 UTC 로 읽어 기기 시간으로 바꾼다', () {
    DateTime createdAtOf(String raw) =>
        MeetingNoteResponse.fromJson({'createdAt': raw}).createdAt;

    // 서버가 실제로 주는 모양. 2026-11-10 01:37:15 UTC 에 저장한 값이다.
    final plain = createdAtOf('2026-11-10T01:37:15.155626');
    expect(plain.isUtc, isFalse);
    expect(plain.toUtc(), DateTime.utc(2026, 11, 10, 1, 37, 15, 155, 626));

    // 오프셋이 붙어 오면 그 오프셋을 따른다.
    expect(
      createdAtOf('2026-11-10T10:37:15+09:00').toUtc(),
      DateTime.utc(2026, 11, 10, 1, 37, 15),
    );

    // 날짜만 와도 던지지 않는다.
    expect(createdAtOf('2026-11-10'), DateTime(2026, 11, 10));
  });

  test('요청은 섹션을 JSON 문자열 content 로 보낸다', () {
    const sections = {'안건': '1. 배포'};

    expect(
      const CreateMeetingNoteRequest(
        templateId: 3,
        title: '회의',
        sections: sections,
        attachments: [],
      ).toJson(),
      {
        'templateId': 3,
        'title': '회의',
        'content': '{"안건":"1. 배포"}',
        'attachments': <Object>[],
      },
    );
    expect(
      const UpdateMeetingNoteRequest(
        title: '회의',
        sections: sections,
        attachments: [],
      ).toJson(),
      {'title': '회의', 'content': '{"안건":"1. 배포"}', 'attachments': <Object>[]},
    );
  });

  test('요청은 첨부를 objectKey·name 목록으로 보낸다', () {
    const attachment = MeetingNoteAttachmentRequest(
      objectKey: 'chat-files/10/1/a.pdf',
      name: '자료.pdf',
    );

    expect(
      const UpdateMeetingNoteRequest(
        title: '회의',
        sections: {},
        attachments: [attachment],
      ).toJson()['attachments'],
      [
        {'objectKey': 'chat-files/10/1/a.pdf', 'name': '자료.pdf'},
      ],
    );
  });

  test('응답의 첨부를 화면 모델로 옮기고, 없으면 빈 목록으로 본다', () {
    const author = NoteAuthor(authorId: 1, name: 'a', initial: 'A', date: '');
    final withFiles = MeetingNoteResponse.fromJson({
      'content': '{}',
      'attachments': [
        {'objectKey': 'chat-files/10/1/a.pdf', 'name': '자료.pdf'},
      ],
    }).toNote(author);

    expect(withFiles.attachments, [
      const NoteAttachment(objectKey: 'chat-files/10/1/a.pdf', name: '자료.pdf'),
    ]);
    expect(
      MeetingNoteResponse.fromJson({
        'content': '{}',
      }).toNote(author).attachments,
      isEmpty,
    );
  });
}
