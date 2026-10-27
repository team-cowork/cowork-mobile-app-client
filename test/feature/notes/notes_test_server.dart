import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/notes/data/notes_repository.dart';
import 'package:cowork_app/feature/team/data/repositories/team_repository.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// 회의록 화면 테스트용 가짜 게이트웨이.
///
/// 팀 1 → 채널 10 하나에 회의록 셋을 담아 둔다. 작성·수정도 이 목록에 반영해,
/// 화면이 저장한 뒤 목록을 다시 읽어도 같은 서버를 보게 한다. 게이트웨이처럼
/// 서비스 prefix(`/team`, `/channel`, `/user`)로 요청을 가르고, 모르는 경로는
/// 404 로 답해 다른 서비스로 간 요청을 드러낸다. 작성 실패는 [failCreate] 로 건다.
class FakeNotesServer implements HttpClientAdapter {
  final List<Map<String, dynamic>> notes = [..._seed];

  /// 걸어 두면 회의록 작성을 이 (상태 코드, 사유)로 거절한다.
  (int, String)? failCreate;

  int _nextId = 100;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path.replaceFirst('/api', '');
    final body = await _body(requestStream);

    if ((path, options.method, failCreate) case (
      '/channel/channels/10/meeting-notes',
      'POST',
      (final statusCode, final message),
    )) {
      return _json({'message': message}, statusCode);
    }

    final data = switch (path) {
      '/team/teams' => [
        {'id': 1, 'name': '코워크팀'},
      ],
      '/channel/teams/1/channels' => [
        {'id': 10, 'name': '일반', 'type': 'TEXT', 'viewType': 'TEXT'},
      ],
      '/channel/channels/10/meeting-note-templates' => [
        {'id': 5, 'name': '회의록', 'isActive': true},
      ],
      '/channel/channels/10/meeting-notes' when options.method == 'GET' =>
        notes,
      '/channel/channels/10/meeting-notes' => _create(body),
      _ when path.startsWith('/channel/channels/10/meeting-notes/') => _update(
        int.parse(path.split('/').last),
        body,
      ),
      _ when path.startsWith('/user/users/') => {
        'id': int.parse(path.split('/').last),
        'name': _names[int.parse(path.split('/').last)],
      },
      _ => null,
    };

    return data == null
        ? _json({'message': '없는 경로: $path'}, 404)
        : _json({'status': 'OK', 'code': 200, 'message': 'OK', 'data': data});
  }

  static ResponseBody _json(Object body, [int statusCode = 200]) =>
      ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  Map<String, dynamic> _create(Map<String, dynamic> body) {
    final note = {
      'id': _nextId++,
      'channelId': 10,
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

  static final _seed = [
    {
      'id': 1,
      'channelId': 10,
      'title': '2026 1분기 킥오프 회의',
      // 작성자 1 = 로그인 사용자(ProfileStore.currentUserId) → 내 회의록.
      'createdBy': 1,
      'createdAt': '2026-03-12T09:00:00Z',
      'content': jsonEncode({
        '요약': '분기 목표 정렬 및 팀별 OKR 확정.',
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
      'title': '디자인 시스템 리뷰',
      'createdBy': 2,
      'createdAt': '2026-03-08T09:00:00Z',
      'content': jsonEncode({'요약': '컬러·타이포 토큰 확정.'}),
    },
    {
      'id': 3,
      'channelId': 10,
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

/// [FakeNotesServer] 를 보는 [NotesRepository] 를 깔고 [home] 을 띄운다.
///
/// 저장소는 `MaterialApp` 바깥에 둔다. 편집 화면처럼 새 라우트로 열리는 화면은
/// `home` 아래에 깐 provider 를 보지 못하기 때문이다(main.dart 와 같은 배치).
Widget notesTestApp(Widget home, FakeNotesServer server) =>
    RepositoryProvider.value(
      value: notesRepositoryOf(server),
      child: MaterialApp(theme: AppTheme.dark(), home: home),
    );

/// [notesTestApp] 의 go_router 판. 상세·편집으로 라우트를 타는 테스트가 쓴다.
Widget notesRouterTestApp(GoRouter router, FakeNotesServer server) =>
    RepositoryProvider.value(
      value: notesRepositoryOf(server),
      child: MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
    );
