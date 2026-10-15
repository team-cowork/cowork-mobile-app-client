import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/chat/data/chat_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 채팅 홈 테스트용 가짜 게이트웨이.
///
/// 팀·채널을 들고 있다가 게이트웨이처럼 서비스 prefix(`/team`, `/channel`)로 요청을
/// 가른다. 단계별로 실패([failTeams]·[failChannels]·[failCreate])나 응답 지연
/// ([createGate])을 걸어, 화면이 어느 단계가 실패했는지 구분하는지 확인한다.
class FakeChatServer implements HttpClientAdapter {
  FakeChatServer({
    List<Map<String, dynamic>>? teams,
    Map<int, List<Map<String, dynamic>>>? channels,
  }) : teams =
           teams ??
           [
             {'id': 1, 'name': '코워크', 'iconUrl': null, 'myRole': 'OWNER'},
             {'id': 2, 'name': '디자인팀', 'iconUrl': null, 'myRole': 'MEMBER'},
           ],
       channels =
           channels ??
           {
             1: [
               {'id': 10, 'name': '일반', 'type': 'TEXT', 'viewType': 'TEXT'},
               {'id': 11, 'name': '배포', 'type': 'TEXT', 'viewType': 'WEBHOOK'},
             ],
             2: [
               {
                 'id': 20,
                 'name': '시안',
                 'type': 'TEXT',
                 'viewType': 'FILE_SHARE',
               },
             ],
           };

  final List<Map<String, dynamic>> teams;
  final Map<int, List<Map<String, dynamic>>> channels;

  /// 걸어 두면 해당 단계가 그 실패로 응답한다.
  ServerFailure? failTeams;
  ServerFailure? failChannels;
  ServerFailure? failCreate;

  /// 걸어 두면 채널 생성 응답을 이 Future 가 끝날 때까지 붙잡는다.
  Future<void>? createGate;

  /// 채널 생성 요청 본문.
  final created = <Map<String, dynamic>>[];

  int _nextId = 100;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path.replaceFirst('/api', '');
    final body = await _body(requestStream);

    if (path == '/team/teams') {
      return _respond(options, failTeams, () => teams);
    }
    if (path.startsWith('/channel/teams/')) {
      final teamId = int.parse(path.split('/')[3]);
      return _respond(options, failChannels, () => channels[teamId] ?? []);
    }
    if (path == '/channel/channels' && options.method == 'POST') {
      await createGate;
      return _respond(options, failCreate, () => _create(body));
    }
    return _json({'message': '없는 경로: $path'}, 404);
  }

  Map<String, dynamic> _create(Map<String, dynamic> body) {
    created.add(body);
    final channel = {
      'id': _nextId++,
      'teamId': body['teamId'],
      'name': body['name'],
      'type': body['type'],
      'viewType': body['viewType'],
      'isPrivate': body['isPrivate'],
    };
    channels.putIfAbsent(body['teamId'] as int, () => []).add(channel);
    return channel;
  }

  static ResponseBody _respond(
    RequestOptions options,
    ServerFailure? failure,
    Object? Function() data,
  ) {
    if (failure == null) {
      return _json({
        'status': 'OK',
        'code': 200,
        'message': 'OK',
        'data': data(),
      });
    }
    final statusCode = failure.statusCode;
    if (statusCode == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: '연결 끊김',
      );
    }
    return _json({'message': failure.message}, statusCode);
  }

  static ResponseBody _json(Object body, [int statusCode = 200]) =>
      ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  static Future<Map<String, dynamic>> _body(Stream<Uint8List>? stream) async {
    if (stream == null) return const {};
    final bytes = (await stream.toList()).expand((chunk) => chunk).toList();
    if (bytes.isEmpty) return const {};
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  @override
  void close({bool force = false}) {}
}

/// 가짜 서버가 돌려줄 실패. [statusCode] 가 null 이면 연결 자체가 끊긴 것으로 본다.
class ServerFailure {
  const ServerFailure(this.statusCode, [this.message]);

  const ServerFailure.offline() : statusCode = null, message = null;

  final int? statusCode;
  final String? message;
}

/// [server] 로 요청을 보내는 저장소. 실제와 같은 서비스별 baseUrl 을 쓴다.
ChatRepository chatRepositoryOf(FakeChatServer server) {
  Dio dio(String service) => Dio(
    BaseOptions(
      baseUrl: 'https://example.test/api/$service',
      contentType: Headers.jsonContentType,
      responseType: ResponseType.plain,
    ),
  )..httpClientAdapter = server;

  return ChatRepository.withDio(team: dio('team'), channel: dio('channel'));
}

/// [home] 을 [server] 에 붙은 [ChatRepository] 와 함께 띄우는 앱.
Widget chatTestApp(
  FakeChatServer server, {
  required Widget home,
  ThemeData? theme,
}) => RepositoryProvider.value(
  value: chatRepositoryOf(server),
  child: MaterialApp(theme: theme, home: home),
);
