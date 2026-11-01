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
      'GET /chat/chat/channels/10/messages' => await _list(
        uri.queryParameters['before'],
      ),
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

  Future<ResponseBody> _list(String? before) async {
    final page = _page(before);
    await listGate;
    return _ok(page);
  }

  List<Map<String, dynamic>> _page(String? before) {
    final start = before == null
        ? 0
        : messages.indexWhere((m) => m['_id'] == before) + 1;
    return messages.skip(start).take(MessageRepository.pageSize).toList();
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
