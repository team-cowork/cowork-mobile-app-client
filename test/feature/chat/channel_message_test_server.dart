import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:dio/dio.dart';

/// 채널 대화 테스트용 가짜 게이트웨이. 서비스 prefix(`/chat`, `/channel`, `/user`)로
/// 요청을 가르고, 받은 요청을 `METHOD 경로` 로 적어 둔다.
class FakeMessageGateway implements HttpClientAdapter {
  FakeMessageGateway({List<Map<String, dynamic>>? messages})
    : messages =
          messages ??
          [messageJson('m2', 2, '두 번째'), messageJson('m1', 3, '첫 번째')];

  /// 채널 10 의 메시지. 서버처럼 최신순이다.
  final List<Map<String, dynamic>> messages;

  final users = <int, String>{1: '나', 2: '도윤', 3: '서연', 4: '민재'};

  final calls = <String>[];
  final bodies = <String, Map<String, dynamic>>{};

  /// 이 요청에는 500 을 돌려준다.
  String? failing;

  /// 걸어 두면 메시지 목록 응답을 이 Future 가 끝날 때까지 붙잡는다.
  Future<void>? listGate;

  /// 이 커서 파라미터는 모르는 척 무시한다. 아직 배포되지 않은 서버를 흉내 낸다.
  Set<String> ignoredCursors = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final uri = options.uri;
    final path = uri.path.replaceFirst('/api', '');
    final call = '${options.method} $path';
    calls.add(uri.hasQuery ? '$call?${uri.query}' : call);
    if (requestStream != null) {
      final bytes = (await requestStream.toList()).expand((c) => c).toList();
      if (bytes.isNotEmpty) {
        bodies[call] = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      }
    }
    if (call == failing) return _json({'message': '서버 오류'}, 500);

    return switch (call) {
      'GET /channel/channels/10' => _ok({
        'id': 10,
        'name': '백엔드',
        'description': 'API 논의',
        'viewType': 'TEXT',
        'teamId': 1,
      }),
      'GET /chat/chat/channels/10/messages' => await _list(uri.queryParameters),
      'POST /chat/chat/channels/10/messages' => _ok({'queued': true}),
      'GET /user/users/me' => _ok({'id': 1, 'name': '나'}),
      'GET /user/users/batch' => _ok({
        'users': [
          for (final id in uri.queryParameters['ids']!.split(','))
            {'id': int.parse(id), 'name': users[int.parse(id)] ?? ''},
        ],
      }),
      _ => ResponseBody.fromString('', 204),
    };
  }

  /// 서버처럼 `before`, `after`, `around` 커서 중 하나로 최신순 한 페이지를 준다.
  /// `around` 메시지가 없으면 404.
  Future<ResponseBody> _list(Map<String, String> received) async {
    final query = {...received}
      ..removeWhere((key, _) => ignoredCursors.contains(key));
    final around = query['around'];
    if (around != null && _indexOf(around) == -1) {
      return _json({'message': '메시지를 찾을 수 없습니다'}, 404);
    }
    final page = _page(query);
    await listGate;
    return _ok(page);
  }

  int _indexOf(String id) => messages.indexWhere((m) => m['_id'] == id);

  List<Map<String, dynamic>> _page(Map<String, String> query) {
    const size = MessageRepository.pageSize;
    const half = MessageRepository.aroundHalf;
    if (query['around'] case final around?) {
      // 이후 쪽 half 개, 기준 포함 이전 쪽 half 개.
      final index = _indexOf(around);
      return [
        ...messages.sublist((index - half).clamp(0, index), index),
        ...messages.skip(index).take(half),
      ];
    }
    if (query['after'] case final after?) {
      final index = _indexOf(after);
      return messages.sublist((index - size).clamp(0, index), index);
    }
    final before = query['before'];
    final start = before == null ? 0 : _indexOf(before) + 1;
    return messages.skip(start).take(size).toList();
  }

  static ResponseBody _ok(Object data) =>
      _json({'status': 'OK', 'code': 200, 'message': 'OK', 'data': data});

  static ResponseBody _json(Object body, [int status = 200]) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

/// 서버 메시지 응답 하나. 기본은 채널 10 의 일반 글이다.
Map<String, dynamic> messageJson(
  String id,
  int authorId,
  String content, {
  int channelId = 10,
  String? clientMessageId,
  String type = 'TEXT',
  String createdAt = '2026-10-23T05:00:00.000Z',
}) => {
  '_id': id,
  'teamId': 1,
  'channelId': channelId,
  'authorId': authorId,
  'content': content,
  'type': type,
  'parentMessageId': null,
  'clientMessageId': clientMessageId,
  'createdAt': createdAt,
};

/// [gateway] 로 [service] 요청을 보내는 dio. 실제와 같은 서비스별 baseUrl 을 쓴다.
Dio messageDio(FakeMessageGateway gateway, String service) => Dio(
  BaseOptions(
    baseUrl: 'https://example.test/api/$service',
    contentType: Headers.jsonContentType,
    responseType: ResponseType.plain,
  ),
)..httpClientAdapter = gateway;
