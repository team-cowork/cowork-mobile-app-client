import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:cowork_app/feature/team/data/repositories/team_repository.dart';
import 'package:dio/dio.dart';

/// 팀 설정 테스트용 가짜 게이트웨이와 스토리지.
///
/// 게이트웨이처럼 서비스 prefix(`/team`, `/user`)로 요청을 가르고, presigned URL 로 온
/// 업로드는 스토리지([storageHost])로 받는다. 받은 요청을 `METHOD 경로` 로 적어 둔다.
class FakeTeamServer implements HttpClientAdapter {
  static const storageHost = 'storage.test';
  static const uploadedIconUrl = 'https://cdn.test/team-icons/new.png';

  /// 팀 1. `PATCH /teams/1` 이 보낸 필드만 덮어쓴다. 소유자는 내(1)가 아니라 2 라서
  /// 내가 할 수 있는 일은 [roles] 로 정해진다.
  final team = <String, dynamic>{
    'id': 1,
    'name': '코워크',
    'description': '협업 서비스',
    'iconUrl': 'https://cdn.test/team-icons/old.png',
    'ownerId': 2,
    'createdAt': '2026-11-01T00:00:00',
    'updatedAt': '2026-11-01T00:00:00',
  };

  /// 나(1)의 팀 1 역할. 모든 멤버에게 붙는 기본 역할만 있고 권한이 없다.
  List<Map<String, dynamic>> roles = [roleJson()];

  final calls = <String>[];

  /// 요청 본문. JSON 이면 디코드한 값, 스토리지 업로드면 바이트 수다.
  final bodies = <String, Object?>{};

  /// 스토리지 업로드 요청의 Content-Type.
  String? uploadedContentType;

  /// 이 요청들에는 [statusCode] 실패를 돌려준다.
  final failing = <String>{};
  int statusCode = 500;

  /// 걸어 두면 스토리지 업로드 응답을 이 Future 가 끝날 때까지 붙잡는다.
  Future<void>? uploadGate;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final uri = options.uri;
    final bytes = requestStream == null
        ? const <int>[]
        : (await requestStream.toList()).expand((chunk) => chunk).toList();

    if (uri.host == storageHost) {
      final call = 'PUT storage${uri.path}';
      calls.add(call);
      bodies[call] = bytes.length;
      uploadedContentType = options.contentType;
      await uploadGate;
      return _respond(call, () => null, empty: true);
    }

    final path = uri.path.replaceFirst('/api', '');
    final call = '${options.method} $path';
    calls.add(call);
    if (bytes.isNotEmpty) bodies[call] = jsonDecode(utf8.decode(bytes));
    final body = bodies[call];

    return switch (call) {
      'GET /team/teams/1' => _respond(call, () => team),
      'PATCH /team/teams/1' => _respond(
        call,
        () => team..addAll(body! as Map<String, dynamic>),
      ),
      'GET /team/teams/1/members/1/roles' => _respond(call, () => roles),
      'POST /team/teams/icon/presigned' => _respond(
        call,
        () => {
          'uploadUrl': 'https://$storageHost/team-icon-uploads/1/new.png',
          'objectKey': 'team-icon-uploads/1/new.png',
        },
      ),
      'POST /team/teams/icon/confirm' => _respond(
        call,
        () => {'iconUrl': uploadedIconUrl},
      ),
      'PATCH /team/teams/1/icon' => _respond(call, () {
        team['iconUrl'] = (body! as Map<String, dynamic>)['iconUrl'];
        return {'iconUrl': team['iconUrl']};
      }),
      'DELETE /team/teams/1/icon' => _respond(call, () {
        team['iconUrl'] = null;
        return null;
      }, empty: true),
      'DELETE /team/teams/1' || 'DELETE /team/teams/1/members/1' => _respond(
        call,
        () => null,
        empty: true,
      ),
      'GET /user/users/me' => _respond(call, () => {'id': 1, 'name': '나'}),
      _ => _json({'message': '없는 경로: $call'}, 404),
    };
  }

  ResponseBody _respond(
    String call,
    Object? Function() data, {
    bool empty = false,
  }) {
    if (failing.contains(call)) {
      return _json({'message': '서버가 거절했다'}, statusCode);
    }
    final value = data();
    if (empty) return ResponseBody.fromString('', 204);
    return _json({'status': 'OK', 'code': 200, 'message': 'OK', 'data': value});
  }

  static ResponseBody _json(Object body, [int statusCode = 200]) =>
      ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

/// 역할 응답 하나. [permissions] 에 없는 키는 꺼져 있다.
Map<String, dynamic> roleJson({
  int id = 1,
  Map<String, bool> permissions = const {},
}) => {
  'id': id,
  'teamId': 1,
  'name': id == 1 ? '@everyone' : '역할 $id',
  'colorHex': '#99AAB5',
  'priority': 0,
  'mentionable': false,
  'permissions': {
    'administrator': false,
    'manage_team': false,
    'delete_team': false,
    ...permissions,
  },
  'isDefault': id == 1,
};

Dio _dioOf(FakeTeamServer server, String service) => Dio(
  BaseOptions(
    baseUrl: 'https://example.test/api/$service',
    contentType: Headers.jsonContentType,
    responseType: ResponseType.plain,
  ),
)..httpClientAdapter = server;

/// [server] 로 요청을 보내는 팀 저장소. 업로드도 같은 [server] 가 받는다.
TeamRepository teamRepositoryOfTeamServer(FakeTeamServer server) =>
    TeamRepository.withDio(
      _dioOf(server, 'team'),
      Dio()..httpClientAdapter = server,
    );

/// [server] 로 요청을 보내는 프로필 저장소. 내 id 를 못 읽었을 때만 쓴다.
ProfileRepository profileRepositoryOfTeamServer(FakeTeamServer server) =>
    ProfileRepository.withDio(_dioOf(server, 'user'));
