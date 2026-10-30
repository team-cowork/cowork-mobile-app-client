import 'package:cowork_app/feature/notes/data/model/requests/template_section_request.dart';
import 'package:cowork_app/feature/notes/data/model/section_type_value.dart';
import 'package:cowork_app/feature/notes/domain/enums/note_section_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notes_test_server.dart';

void main() {
  late FakeNotesServer server;
  setUp(() => server = FakeNotesServer());

  test('채널의 템플릿을 섹션·형식·필수 여부까지 읽는다', () async {
    final templates = await noteTemplateRepositoryOf(server).fetchTemplates(10);

    expect(templates.map((t) => t.name), ['주간 회의', '스프린트 회고']);
    final weekly = templates.first;
    expect(weekly.isDefault, isTrue);
    expect(weekly.channelId, 10);
    expect(weekly.sections.map((s) => s.title), [
      '참석자',
      '안건',
      '결정 사항',
      '액션 아이템',
      '다음 회의',
    ]);
    expect(weekly.sections.first.type, NoteSectionType.userList);
    expect(weekly.sections.first.isRequired, isTrue);
    expect(weekly.sections[1].placeholder, '논의할 주제를 입력하세요');
    // 서버가 null 로 준 안내 문구는 빈 문자열로 받는다.
    expect(weekly.sections[2].placeholder, '');
    expect(weekly.sections.last.type, NoteSectionType.dateTime);

    expect(await noteTemplateRepositoryOf(server).fetchTemplates(11), isEmpty);
  });

  test('모르는 섹션 형식은 긴 텍스트로 본다', () {
    expect(sectionTypeOf('CHECKLIST'), NoteSectionType.markdown);
    expect(sectionTypeOf(null), NoteSectionType.markdown);
    expect(sectionTypeValueOf(NoteSectionType.userList), 'USER_LIST');
  });

  test('새 템플릿은 이름만 보내고, 섹션 없이 기본이 아닌 채로 만들어진다', () async {
    final created = await noteTemplateRepositoryOf(
      server,
    ).createTemplate(11, '1:1 미팅');

    final (method, path, body) = server.requests.last;
    expect(method, 'POST');
    expect(path, '/channel/channels/11/meeting-note-templates');
    expect(body, {'name': '1:1 미팅'});
    expect(created.name, '1:1 미팅');
    expect(created.channelId, 11);
    expect(created.isDefault, isFalse);
    expect(created.sections, isEmpty);
  });

  test('이름을 고치고 기본 템플릿을 바꾼다', () async {
    final repository = noteTemplateRepositoryOf(server);
    final retro = (await repository.fetchTemplates(10)).last;

    final renamed = await repository.renameTemplate(retro, '회고');
    expect(renamed.name, '회고');
    expect(server.requests.last.$3, {'name': '회고'});

    final activated = await repository.setDefault(renamed);
    expect(activated.isDefault, isTrue);
    expect(
      server.requests.last.$2,
      '/channel/channels/10/meeting-note-templates/6/activate',
    );
    // 서버가 이전 기본 템플릿을 해제한다.
    final templates = await repository.fetchTemplates(10);
    expect(templates.map((t) => t.isDefault), [isFalse, isTrue]);
  });

  test('기본 템플릿 삭제는 서버가 거절하고, 다른 템플릿은 지워진다', () async {
    final repository = noteTemplateRepositoryOf(server);
    final [weekly, retro] = await repository.fetchTemplates(10);

    await expectLater(
      repository.deleteTemplate(weekly),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          400,
        ),
      ),
    );

    await repository.deleteTemplate(retro);
    expect((await repository.fetchTemplates(10)).map((t) => t.name), ['주간 회의']);
  });

  test('섹션을 추가·수정·삭제한다', () async {
    final repository = noteTemplateRepositoryOf(server);
    final retro = (await repository.fetchTemplates(10)).last;

    final added = await repository.addSection(
      retro,
      TemplateSectionRequest.of(
        title: '다음 회고',
        type: NoteSectionType.date,
        placeholder: '',
        isRequired: true,
      ),
    );
    final (method, path, body) = server.requests.last;
    expect(method, 'POST');
    expect(path, '/channel/channels/10/meeting-note-templates/6/sections');
    expect(body, {
      'title': '다음 회고',
      'type': 'DATE',
      'placeholder': null,
      'isRequired': true,
    });
    expect(added.type, NoteSectionType.date);
    expect(added.isRequired, isTrue);

    final updated = await repository.updateSection(
      retro,
      added.id,
      TemplateSectionRequest.of(
        title: '다음 회고 일정',
        type: NoteSectionType.dateTime,
        placeholder: '예: 다음 주 금요일',
        isRequired: false,
      ),
    );
    expect(updated.id, added.id);
    expect(updated.title, '다음 회고 일정');
    expect(updated.type, NoteSectionType.dateTime);
    expect(updated.placeholder, '예: 다음 주 금요일');

    await repository.deleteSection(retro, added.id);
    final sections = (await repository.fetchTemplates(10)).last.sections;
    expect(sections.map((s) => s.title), ['Keep', 'Problem', 'Try']);
  });

  test('안내 문구는 서버가 지움과 바꾸지 않음을 구분하는 대로 보낸다', () {
    String? placeholderOf(String placeholder, {String? previous}) =>
        TemplateSectionRequest.of(
          title: '안건',
          type: NoteSectionType.markdown,
          placeholder: placeholder,
          isRequired: false,
          previousPlaceholder: previous,
        ).placeholder;

    // 새 섹션: 비우면 문구 없음(null).
    expect(placeholderOf(''), isNull);
    expect(placeholderOf('예: 안건'), '예: 안건');
    // 수정: 있던 문구를 비우면 빈 문자열로 지운다.
    expect(placeholderOf('', previous: '예: 안건'), '');
    // 수정: 원래 없던 문구는 null 로 그대로 둔다.
    expect(placeholderOf('', previous: ''), isNull);
  });
}
