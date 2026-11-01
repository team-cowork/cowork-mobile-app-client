import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/notes/data/notes_repository.dart';
import 'package:cowork_app/feature/notes/data/repositories/note_template_repository.dart';
import 'package:cowork_app/feature/notes/domain/note.dart';
import 'package:cowork_app/feature/notes/domain/note_draft.dart';
import 'package:cowork_app/feature/notes/domain/note_template.dart';
import 'package:cowork_app/feature/notes/presentation/views/note_detail_view.dart';
import 'package:cowork_app/feature/notes/presentation/views/note_edit_view.dart';
import 'package:cowork_app/feature/notes/presentation/views/note_template_edit_view.dart';
import 'package:cowork_app/feature/notes/presentation/views/note_templates_view.dart';
import 'package:cowork_app/feature/notes/presentation/views/notes_view.dart';
import 'package:cowork_app/feature/team/data/repositories/team_repository.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// 회의록 화면 테스트용 가짜 게이트웨이.
///
/// 팀 1 에 회의록 채널 10(템플릿 둘)·11(템플릿 없음)과 일반 채널 12 를 두고, 채널 10
/// 에 회의록 셋을 담아 둔다. 작성·수정·템플릿 변경도 이 목록에 반영해, 화면이 저장한
/// 뒤 다시 읽어도 같은 서버를 보게 한다. 게이트웨이처럼 서비스 prefix(`/team`,
/// `/channel`, `/user`)로 요청을 가르고, 모르는 경로는 404 로 답해 다른 서비스로 간
/// 요청을 드러낸다. 작성 실패는 [failCreate] 로 건다.
class FakeNotesServer implements HttpClientAdapter {
  final List<Map<String, dynamic>> notes = _seedNotes();

  /// 채널 id → 템플릿(섹션 포함). 서버 응답 모양 그대로다.
  final Map<int, List<Map<String, dynamic>>> templates = {
    10: _seedTemplates(),
    11: [],
  };

  /// 받은 요청 (메서드, 경로, 본문). 요청 본문을 확인할 때 쓴다.
  final List<(String, String, Map<String, dynamic>)> requests = [];

  /// 걸어 두면 회의록 작성을 이 (상태 코드, 사유)로 거절한다.
  (int, String)? failCreate;

  /// 채널 id → 끝낼 때까지 그 채널의 템플릿 목록 응답을 붙잡아 둘 completer.
  final Map<int, Completer<void>> holdTemplates = {};

  int _nextId = 100;

  static final _notesPath = RegExp(
    r'^/channel/channels/(\d+)/meeting-notes(?:/(\d+))?$',
  );

  static final _templatesPath = RegExp(
    r'^/channel/channels/(\d+)/meeting-note-templates'
    r'(?:/(\d+)(?:/(activate|sections)(?:/(\d+))?)?)?$',
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path.replaceFirst('/api', '');
    final method = options.method;
    final body = await _body(requestStream);
    requests.add((method, path, body));

    if (_templatesPath.firstMatch(path) case final match?) {
      final channelId = int.parse(match[1]!);
      if (method == 'GET') await holdTemplates[channelId]?.future;
      return _template(
        method,
        channelId: channelId,
        templateId: int.tryParse(match[2] ?? ''),
        action: match[3],
        sectionId: int.tryParse(match[4] ?? ''),
        body: body,
      );
    }

    if (_notesPath.firstMatch(path) case final match?) {
      final channelId = int.parse(match[1]!);
      if (match[2] case final id?) return _ok(_update(int.parse(id), body));
      if (method == 'GET') {
        return _ok([
          for (final note in notes)
            if (note['channelId'] == channelId) note,
        ]);
      }
      if (failCreate case (final statusCode, final message)) {
        return _json({'message': message}, statusCode);
      }
      return _ok(_create(channelId, body), 201);
    }

    final data = switch (path) {
      '/team/teams' => [
        {'id': 1, 'name': '코워크팀'},
      ],
      '/channel/teams/1/channels' => [
        {'id': 10, 'name': '회의록', 'type': 'TEXT', 'viewType': 'MEETING_NOTE'},
        {'id': 11, 'name': '주간 회의', 'type': 'TEXT', 'viewType': 'MEETING_NOTE'},
        {'id': 12, 'name': '일반', 'type': 'TEXT', 'viewType': 'TEXT'},
      ],
      _ when path.startsWith('/user/users/') => {
        'id': int.parse(path.split('/').last),
        'name': _names[int.parse(path.split('/').last)],
      },
      _ => null,
    };

    return data == null ? _json({'message': '없는 경로: $path'}, 404) : _ok(data);
  }

  /// 템플릿·섹션 요청. 서버처럼 기본(활성) 템플릿 삭제는 400 으로 거절한다.
  ResponseBody _template(
    String method, {
    required int channelId,
    required int? templateId,
    required String? action,
    required int? sectionId,
    required Map<String, dynamic> body,
  }) {
    final list = templates.putIfAbsent(channelId, () => []);
    if (templateId == null) {
      if (method == 'GET') return _ok(list);
      final created = {
        'id': _nextId++,
        'channelId': channelId,
        'name': body['name'],
        'isActive': false,
        'sections': <Map<String, dynamic>>[],
      };
      list.add(created);
      return _ok(created, 201);
    }

    final template = list.where((t) => t['id'] == templateId).firstOrNull;
    if (template == null) {
      return _json({'message': '템플릿을 찾을 수 없습니다.'}, 404);
    }
    final sections = template['sections'] as List<Map<String, dynamic>>;

    switch ((method, action)) {
      case ('GET', null):
        return _ok(template);
      case ('PATCH', null):
        template['name'] = body['name'];
        return _ok(template);
      case ('DELETE', null):
        if (template['isActive'] == true) {
          return _json({'message': '활성 템플릿은 삭제할 수 없습니다.'}, 400);
        }
        list.remove(template);
        return _noContent();
      case ('PATCH', 'activate'):
        for (final other in list) {
          other['isActive'] = identical(other, template);
        }
        return _ok(template);
      case ('POST', 'sections'):
        final section = {'id': _nextId++, 'templateId': templateId, ...body};
        sections.add(section);
        return _ok(section, 201);
      case ('PATCH', 'sections'):
        final section = sections.firstWhere((s) => s['id'] == sectionId)
          ..addAll(body);
        return _ok(section);
      case ('DELETE', 'sections'):
        sections.removeWhere((s) => s['id'] == sectionId);
        return _noContent();
    }
    return _json({'message': '없는 경로'}, 404);
  }

  static ResponseBody _ok(Object? data, [int statusCode = 200]) => _json({
    'status': 'OK',
    'code': statusCode,
    'message': 'OK',
    'data': data,
  }, statusCode);

  static ResponseBody _noContent() => ResponseBody.fromString('', 204);

  static ResponseBody _json(Object body, [int statusCode = 200]) =>
      ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  Map<String, dynamic> _create(int channelId, Map<String, dynamic> body) {
    final note = {
      'id': _nextId++,
      'channelId': channelId,
      'templateId': body['templateId'],
      'title': body['title'],
      'content': body['content'],
      'createdBy': 1,
      'createdAt': '2026-03-20T09:00:00Z',
    };
    notes.insert(0, note);
    return note;
  }

  Map<String, dynamic> _update(int id, Map<String, dynamic> body) {
    final index = notes.indexWhere((note) => note['id'] == id);
    return notes[index] = {...notes[index], ...body};
  }

  static Future<Map<String, dynamic>> _body(Stream<Uint8List>? stream) async {
    if (stream == null) return const {};
    final bytes = (await stream.toList()).expand((chunk) => chunk).toList();
    if (bytes.isEmpty) return const {};
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  @override
  void close({bool force = false}) {}

  static const _names = {1: '김준혁', 2: '도윤', 3: '서연', 4: '민재'};

  /// 채널 10 의 템플릿. `주간 회의` 가 기본이다.
  static List<Map<String, dynamic>> _seedTemplates() => [
    {
      'id': 5,
      'channelId': 10,
      'name': '주간 회의',
      'isActive': true,
      'sections': <Map<String, dynamic>>[
        _section(51, 5, '참석자', 'USER_LIST', isRequired: true),
        _section(
          52,
          5,
          '안건',
          'MARKDOWN',
          placeholder: '논의할 주제를 입력하세요',
          isRequired: true,
        ),
        _section(53, 5, '결정 사항', 'MARKDOWN'),
        _section(54, 5, '액션 아이템', 'MARKDOWN'),
        _section(55, 5, '다음 회의', 'DATETIME'),
      ],
    },
    {
      'id': 6,
      'channelId': 10,
      'name': '스프린트 회고',
      'isActive': false,
      'sections': <Map<String, dynamic>>[
        _section(61, 6, 'Keep', 'MARKDOWN'),
        _section(62, 6, 'Problem', 'MARKDOWN'),
        _section(63, 6, 'Try', 'MARKDOWN'),
      ],
    },
  ];

  static Map<String, dynamic> _section(
    int id,
    int templateId,
    String title,
    String type, {
    String? placeholder,
    bool isRequired = false,
  }) => {
    'id': id,
    'templateId': templateId,
    'title': title,
    'type': type,
    'placeholder': placeholder,
    'isRequired': isRequired,
  };

  static List<Map<String, dynamic>> _seedNotes() => [
    {
      'id': 1,
      'channelId': 10,
      'templateId': 5,
      'title': '2026 1분기 킥오프 회의',
      // 작성자 1 = 로그인 사용자(ProfileStore.currentUserId) → 내 회의록.
      'createdBy': 1,
      'createdAt': '2026-03-12T09:00:00Z',
      // `요약` 은 템플릿에 없는 섹션이다. 예전 앱이 고정 키로 쓰던 본문.
      'content': jsonEncode({
        '요약': '분기 목표 정렬 및 팀별 OKR 확정.',
        '참석자': '김준혁, 도윤, 서연',
        '안건': '1. 1분기 팀 목표 및 OKR 정렬\n2. 채팅·이슈 트래커 MVP 범위',
        '결정 사항': '· 채팅과 이슈 트래커를 1차 MVP로 확정.',
        '액션 아이템':
            '- [x] Riverpod 상태 구조 초안 공유 (junjuny)\n'
            '- [ ] 이슈 트래커 칸반 스펙 문서화 (민재)\n'
            '- [ ] 음성 채널 인원 제한 정책 확정 (서연)',
      }),
    },
    {
      'id': 2,
      'channelId': 10,
      'templateId': 5,
      'title': '디자인 시스템 리뷰',
      'createdBy': 2,
      'createdAt': '2026-03-08T09:00:00Z',
      'content': jsonEncode({'요약': '컬러·타이포 토큰 확정.'}),
    },
    {
      'id': 3,
      'channelId': 10,
      'templateId': 6,
      'title': '스프린트 회고 #3',
      'createdBy': 4,
      'createdAt': '2026-02-28T09:00:00Z',
      'content': jsonEncode({'요약': '완료 항목 점검 및 블로커 정리.'}),
    },
  ];
}

/// [server] 로 [service] 요청을 보내는 dio. 실제와 같은 서비스별 baseUrl 을 쓴다.
Dio _dioOf(HttpClientAdapter server, String service) => Dio(
  BaseOptions(
    baseUrl: 'https://example.test/api/$service',
    contentType: Headers.jsonContentType,
    responseType: ResponseType.plain,
  ),
)..httpClientAdapter = server;

/// [server] 로 요청을 보내는 회의록 저장소. 팀·채널 목록도 같은 서버에서 읽는다.
NotesRepository notesRepositoryOf(HttpClientAdapter server) =>
    NotesRepository.withDio(
      _dioOf(server, 'channel'),
      users: _dioOf(server, 'user'),
      teams: TeamRepository.withDio(_dioOf(server, 'team')),
      channels: ChannelRepository.withDio(_dioOf(server, 'channel')),
    );

/// [server] 로 요청을 보내는 회의록 템플릿 저장소.
NoteTemplateRepository noteTemplateRepositoryOf(HttpClientAdapter server) =>
    NoteTemplateRepository.withDio(_dioOf(server, 'channel'));

/// 회의록·템플릿 저장소를 `MaterialApp` 바깥에 깐다. 편집 화면처럼 새 라우트로
/// 열리는 화면은 `home` 아래에 깐 provider 를 보지 못하기 때문이다(main.dart 와
/// 같은 배치).
Widget _withRepositories(FakeNotesServer server, Widget app) =>
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: notesRepositoryOf(server)),
        RepositoryProvider.value(value: noteTemplateRepositoryOf(server)),
      ],
      child: app,
    );

/// [FakeNotesServer] 를 보는 저장소를 깔고 [home] 을 띄운다.
Widget notesTestApp(Widget home, FakeNotesServer server) =>
    _withRepositories(server, MaterialApp(theme: AppTheme.dark(), home: home));

/// [notesTestApp] 의 go_router 판. 상세·편집으로 라우트를 타는 테스트가 쓴다.
Widget notesRouterTestApp(GoRouter router, FakeNotesServer server) =>
    _withRepositories(
      server,
      MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
    );

/// 회의록 기능의 라우트를 모두 단 go_router. app_router.dart 와 같은 경로다.
GoRouter notesTestRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const NotesView()),
    GoRoute(
      path: '/notes/detail',
      builder: (context, state) => NoteDetailView(note: state.extra! as Note),
    ),
    GoRoute(
      path: '/notes/edit',
      builder: (context, state) => NoteEditView(note: state.extra! as Note),
    ),
    GoRoute(
      path: '/notes/new',
      builder: (context, state) =>
          NoteEditView.create(draft: state.extra! as NoteDraft),
    ),
    GoRoute(
      path: '/notes/templates',
      builder: (context, state) =>
          NoteTemplatesView(channelId: state.extra as int?),
    ),
    GoRoute(
      path: '/notes/templates/edit',
      builder: (context, state) =>
          NoteTemplateEditView(template: state.extra! as NoteTemplate),
    ),
  ],
);
