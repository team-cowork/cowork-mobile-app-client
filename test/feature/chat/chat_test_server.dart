import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/chat/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/team_repository.dart';
import 'package:cowork_app/network/chat_socket.dart';
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
  ServerFailure? failCreateTeam;

  /// 걸어 두면 채널 생성 응답을 이 Future 가 끝날 때까지 붙잡는다.
  Future<void>? createGate;

  /// 팀 id 별로 걸어 두면 그 팀 채널 목록 응답을 이 Future 가 끝날 때까지 붙잡는다.
  final channelGates = <int, Future<void>>{};

  /// 채널 생성 요청 본문.
  final created = <Map<String, dynamic>>[];

  /// 팀 생성 요청 본문.
  final createdTeams = <Map<String, dynamic>>[];

  int _nextId = 100;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path.replaceFirst('/api', '');
    final body = await _body(requestStream);

    if (path == '/team/teams' && options.method == 'POST') {
      return _respond(options, failCreateTeam, () => _createTeam(body));
    }
    if (path == '/team/teams') {
      return _respond(options, failTeams, () => teams);
    }
    if (path.startsWith('/channel/teams/')) {
      final teamId = int.parse(path.split('/')[3]);
      await channelGates[teamId];
      return _respond(options, failChannels, () => channels[teamId] ?? []);
    }
    if (path == '/channel/channels' && options.method == 'POST') {
      await createGate;
      return _respond(options, failCreate, () => _create(body));
    }
    return _json({'message': '없는 경로: $path'}, 404);
  }

  /// 서버처럼 팀만 만들고 채널은 만들지 않는다.
  Map<String, dynamic> _createTeam(Map<String, dynamic> body) {
    createdTeams.add(body);
    final team = {
      'id': _nextId++,
      'name': body['name'],
      'description': body['description'],
      'iconUrl': null,
      'ownerId': 1,
    };
    teams.add({...team, 'myRole': 'OWNER'});
    return team;
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

/// [server] 로 [service] 요청을 보내는 dio. 실제와 같은 서비스별 baseUrl 을 쓴다.
Dio _dioOf(FakeChatServer server, String service) => Dio(
  BaseOptions(
    baseUrl: 'https://example.test/api/$service',
    contentType: Headers.jsonContentType,
    responseType: ResponseType.plain,
  ),
)..httpClientAdapter = server;

/// [server] 로 요청을 보내는 팀 저장소.
TeamRepository teamRepositoryOf(FakeChatServer server) =>
    TeamRepository.withDio(_dioOf(server, 'team'));

/// [server] 로 요청을 보내는 채널 저장소.
ChannelRepository channelRepositoryOf(FakeChatServer server) =>
    ChannelRepository.withDio(_dioOf(server, 'channel'));

/// 가짜 채팅 소켓. 구독한 팀·채널 방을 기록하고, 테스트가 서버 이벤트를 [push] 한다.
class FakeChatSocket implements ChatSocket {
  final _events = StreamController<SocketEvent>.broadcast();

  /// 지금 구독 중인 팀 방.
  final joined = <int>{};

  /// 서버가 [name] 이벤트를 보낸 것처럼 흘린다.
  void push(String name, Map<String, dynamic> data) =>
      _events.add((name: name, data: data));

  @override
  Stream<SocketEvent> get events => _events.stream;

  @override
  void joinTeam(int teamId) => joined.add(teamId);

  @override
  void leaveTeam(int teamId) => joined.remove(teamId);

  /// 지금 구독 중인 채널 방.
  final joinedChannels = <int>{};

  @override
  void joinChannel(int channelId) => joinedChannels.add(channelId);

  @override
  void leaveChannel(int channelId) => joinedChannels.remove(channelId);

  @override
  Iterable<int> get joinedChannelIds => joinedChannels;

  final _reconnected = StreamController<void>.broadcast();

  /// 끊김 복구 없이 다시 연결된 것처럼 알린다.
  void reconnect() => _reconnected.add(null);

  @override
  Stream<void> get reconnected => _reconnected.stream;

  @override
  void dispose() {
    _events.close();
    _reconnected.close();
  }
}

/// [home] 을 [server] 에 붙은 팀·채널 저장소와 [socket] 과 함께 띄우는 앱.
Widget chatTestApp(
  FakeChatServer server, {
  required Widget home,
  FakeChatSocket? socket,
  ThemeData? theme,
}) => MultiRepositoryProvider(
  providers: [
    RepositoryProvider.value(value: teamRepositoryOf(server)),
    RepositoryProvider.value(value: channelRepositoryOf(server)),
    RepositoryProvider<ChatSocket>.value(value: socket ?? FakeChatSocket()),
  ],
  child: MaterialApp(theme: theme, home: home),
);
