import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/search/data/repositories/search_repository.dart';
import 'package:cowork_app/feature/search/domain/search_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 받은 요청을 `경로?쿼리` 로 적어 두고, 경로별로 정해 둔 본문을 주는 서버.
class _SearchServer implements HttpClientAdapter {
  _SearchServer(this.responses);

  /// 게이트웨이 `/api` 를 뗀 경로 → 응답 본문.
  final Map<String, Object> responses;
  final calls = <Uri>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options.uri);
    final body = responses[options.uri.path.replaceFirst('/api', '')];
    if (body == null) return ResponseBody.fromString('', 404);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

SearchRepository _repository(_SearchServer server) {
  Dio dio(String service) => Dio(
    BaseOptions(
      baseUrl: 'https://example.test/api/$service',
      responseType: ResponseType.plain,
    ),
  )..httpClientAdapter = server;
  return SearchRepository.withDio(
    channel: dio('channel'),
    chat: dio('chat'),
    user: dio('user'),
  );
}

void main() {
  test('채널 검색은 팀과 검색어로 channel 서비스를 부르고 설명을 미리보기로 쓴다', () async {
    final server = _SearchServer({
      '/channel/search/channels': {
        'data': [
          {'id': 6, 'name': '백엔드', 'description': '서버 이야기'},
          {'id': 7, 'name': '백엔드-배포', 'description': null},
        ],
      },
    });

    final channels = await _repository(
      server,
    ).searchChannels(teamId: 3, query: '백엔드');

    expect(server.calls.single.queryParameters, {'teamId': '3', 'q': '백엔드'});
    expect(channels, const [
      SearchChannelResult(id: '6', name: '백엔드', description: '서버 이야기'),
      SearchChannelResult(id: '7', name: '백엔드-배포', description: ''),
    ]);
  });

  test('사람 검색은 이름이 비면 닉네임을, 역할에는 직군을 쓴다', () async {
    final server = _SearchServer({
      '/user/users/search': {
        'data': {
          'items': [
            {'id': 1, 'name': '도윤', 'specialty': '백엔드 개발자'},
            {'id': 2, 'name': '', 'nickname': 'seo', 'specialty': null},
          ],
          'page': 1,
          'page_size': 20,
          'total_count': 2,
          'has_next': false,
        },
      },
    });

    final people = await _repository(
      server,
    ).searchPeople(teamId: 3, query: '도');

    expect(server.calls.single.queryParameters, {
      'teamId': '3',
      'q': '도',
      'page_size': '${SearchRepository.peoplePageSize}',
    });
    expect(
      [for (final p in people) (p.id, p.name, p.role, p.initial)],
      [('1', '도윤', '백엔드 개발자', '도'), ('2', 'seo', '', 's')],
    );
  });

  test('메시지 검색은 커서를 before 로 보내고 nextCursor 를 돌려준다', () async {
    final server = _SearchServer({
      '/chat/chat/search/messages': {
        'messages': [
          {
            'messageId': 'm1',
            'channelId': 6,
            'authorId': 211,
            'content': '재연결 로직 리뷰',
            'highlight': ['<em>재연결</em> 로직 리뷰'],
            'type': 'TEXT',
            'hasAttachments': false,
            'isPinned': false,
            'createdAt': '2026-11-01T03:00:00.000Z',
          },
        ],
        'nextCursor': 'cursor-2',
      },
    });

    final page = await _repository(
      server,
    ).searchMessages(teamId: 3, query: '재연결', before: 'cursor-1');

    expect(server.calls.single.queryParameters, {
      'teamId': '3',
      'q': '재연결',
      'limit': '${SearchRepository.messagePageSize}',
      'before': 'cursor-1',
    });
    expect(page.nextCursor, 'cursor-2');
    expect(page.hasMore, isTrue);
    expect(page.messages.single.highlights, ['<em>재연결</em> 로직 리뷰']);
    expect(page.messages.single.createdAt, DateTime.utc(2026, 11, 1, 3));
  });

  test('첫 페이지는 before 를 보내지 않고, 마지막 페이지면 hasMore 가 false 다', () async {
    final server = _SearchServer({
      '/chat/chat/search/messages': {'messages': [], 'nextCursor': null},
    });

    final page = await _repository(
      server,
    ).searchMessages(teamId: 3, query: '없음');

    expect(server.calls.single.queryParameters.containsKey('before'), isFalse);
    expect(page.hasMore, isFalse);
  });
}
