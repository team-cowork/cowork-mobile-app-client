import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/chat/data/repositories/dm_repository.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:dio/dio.dart';

/// DM 목록 테스트용 가짜 게이트웨이. 서비스 prefix(`/chat`, `/channel`, `/user`)로
/// 요청을 가르고, 받은 요청을 `METHOD 경로` 로 적어 둔다.
class FakeDmGateway implements HttpClientAdapter {
  FakeDmGateway({List<Map<String, dynamic>>? conversations})
    : conversations = conversations ?? [];

  /// `GET /chat/dms` 응답. 서버처럼 마지막 메시지가 최근인 대화가 앞이다.
  final List<Map<String, dynamic>> conversations;

  final users = <int, String>{2: '서연', 3: '도윤', 4: '민재'};

  final calls = <String>[];
  final bodies = <String, Map<String, dynamic>>{};

  /// 이 요청에는 500 을 돌려준다.
  String? failing;

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

    if (options.method == 'DELETE' && path.startsWith('/chat/chat/dms/')) {
      return ResponseBody.fromString('', 204);
    }
    return switch (call) {
      'GET /chat/chat/dms' => _ok(conversations),
      'POST /channel/dms' => _ok({'id': 77, 'name': 'DM', 'viewType': 'TEXT'}),
      'GET /user/users/batch' => _ok({
        'users': [
          for (final id in uri.queryParameters['ids']!.split(','))
            {'id': int.parse(id), 'name': users[int.parse(id)] ?? ''},
        ],
      }),
      _ => ResponseBody.fromString('', 204),
    };
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

/// 서버 DM 대화 하나. 마지막 메시지가 없으면 [content] 를 null 로 준다.
Map<String, dynamic> dmJson(
  int channelId,
  int otherUserId, {
  String? content = '안녕하세요',
  int authorId = 2,
  String type = 'TEXT',
  int unreadCount = 0,
  String createdAt = '2026-11-12T05:00:00.000Z',
}) => {
  'channelId': channelId,
  'otherUserId': otherUserId,
  'unreadCount': unreadCount,
  'lastMessage': content == null
      ? null
      : {
          'messageId': 'm$channelId',
          'authorId': authorId,
          'content': content,
          'type': type,
          'createdAt': createdAt,
        },
};

/// [gateway] 로 [service] 요청을 보내는 dio. 실제와 같은 서비스별 baseUrl 을 쓴다.
Dio dmDio(FakeDmGateway gateway, String service) => Dio(
  BaseOptions(
    baseUrl: 'https://example.test/api/$service',
    contentType: Headers.jsonContentType,
    responseType: ResponseType.plain,
  ),
)..httpClientAdapter = gateway;

DmRepository dmRepositoryOf(FakeDmGateway gateway) => DmRepository.withDio(
  chat: dmDio(gateway, 'chat'),
  channel: dmDio(gateway, 'channel'),
);

ProfileRepository dmProfileRepositoryOf(FakeDmGateway gateway) =>
    ProfileRepository.withDio(dmDio(gateway, 'user'));
