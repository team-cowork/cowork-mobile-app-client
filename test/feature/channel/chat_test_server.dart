import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/core/network/chat_socket.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/notifications/data/repositories/notification_repository.dart';
import 'package:cowork_app/feature/project/data/repositories/project_repository.dart';
import 'package:cowork_app/feature/team/data/repositories/team_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../notifications/notification_test_stream.dart';

/// 채팅 홈 테스트용 가짜 게이트웨이.
///
/// 팀·채널·프로젝트를 들고 있다가 게이트웨이처럼 서비스 prefix(`/team`, `/channel`,
/// `/project`)로 요청을 가른다. 단계별로 실패([failTeams]·[failChannels]·[failCreate])나 응답 지연
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

  /// 팀 id → 프로젝트 목록(서버 순서). 기본은 프로젝트가 없다.
  final projects = <int, List<Map<String, dynamic>>>{};

  /// 프로젝트 생성 요청 본문.
  final createdProjects = <Map<String, dynamic>>[];

  /// 채널 수정 요청 본문(`PATCH /channels/{id}`). 채널 id 와 함께 남긴다.
  final updatedChannels = <(int, Map<String, dynamic>)>[];

  ServerFailure? failProjects;
  ServerFailure? failCreateProject;
  ServerFailure? failUpdateChannel;

  /// 팀 id 별로 걸어 두면 그 팀 프로젝트 목록 응답을 이 Future 가 끝날 때까지 붙잡는다.
  final projectGates = <int, Future<void>>{};

  /// 걸어 두면 해당 단계가 그 실패로 응답한다.
  ServerFailure? failTeams;
  ServerFailure? failChannels;
  ServerFailure? failCreate;
  ServerFailure? failCreateTeam;

  /// 걸어 두면 채널 생성 응답을 이 Future 가 끝날 때까지 붙잡는다.
  Future<void>? createGate;

  /// 팀 id 별로 걸어 두면 그 팀 채널 목록 응답을 이 Future 가 끝날 때까지 붙잡는다.
  final channelGates = <int, Future<void>>{};

  /// 받은 요청. `METHOD 경로` 형식이다.
  final requests = <String>[];

  /// 채널 생성 요청 본문.
  final created = <Map<String, dynamic>>[];

  /// 팀 생성 요청 본문.
  final createdTeams = <Map<String, dynamic>>[];

  /// 초대 코드 → 그 코드로 들어갈 팀. 가입하면 [teams] 에 이 팀이 붙는다.
  final joinableTeams = <String, Map<String, dynamic>>{};

  /// 팀 id → 멤버 사용자 id.
  final members = <int, List<int>>{};

  /// 팀 id → 초대 코드 목록(`GET /invites` 응답 원소).
  final invites = <int, List<Map<String, dynamic>>>{};

  /// 바로 초대 요청 본문.
  final invitedMembers = <Map<String, dynamic>>[];

  ServerFailure? failJoin;
  ServerFailure? failInvite;
  ServerFailure? failInvites;
  ServerFailure? failRevoke;
  ServerFailure? failMembers;

  int _nextId = 100;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path.replaceFirst('/api', '');
    final body = await _body(requestStream);
    requests.add('${options.method} $path');

    if (path == '/team/teams' && options.method == 'POST') {
      return _respond(options, failCreateTeam, () => _createTeam(body));
    }
    if (path == '/team/teams') {
      return _respond(options, failTeams, () => teams);
    }
    if (path.startsWith('/team/teams/join/')) {
      final code = Uri.decodeComponent(path.split('/').last);
      return _respond(options, failJoin, () => _join(code));
    }
    if (path.startsWith('/team/teams/')) {
      final segments = path.split('/');
      final teamId = int.parse(segments[3]);
      final teamInvites = invites.putIfAbsent(teamId, () => []);
      switch ((options.method, segments.length > 4 ? segments[4] : '')) {
        case ('GET', 'members'):
          return _respond(options, failMembers, () => _membersOf(teamId));
        case ('POST', 'members'):
          invitedMembers.add(body);
          return _respond(options, failInvite, () {
            members[teamId] = {
              ...members[teamId] ?? const <int>[],
              ...(body['userIds'] as List).cast<int>(),
            }.toList();
            return _membersOf(teamId);
          });
        case ('GET', 'invites'):
          return _respond(options, failInvites, () => teamInvites);
        case ('POST', 'invites'):
          return _respond(options, failInvite, () {
            final invite = {
              'inviteCode': 'code${_nextId++}',
              'teamId': teamId,
              'duration': body['duration'],
              'expiresAt': body['duration'] == 'never'
                  ? null
                  : '2026-11-24T03:00:00',
              'expired': false,
              'createdAt': '2026-11-17T03:00:00',
            };
            teamInvites.insert(0, invite);
            return invite;
          });
        case ('DELETE', 'invites'):
          final code = Uri.decodeComponent(segments[5]);
          return _respond(options, failRevoke, () {
            for (final invite in teamInvites) {
              if (invite['inviteCode'] == code) invite['expired'] = true;
            }
            return null;
          });
      }
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
    if (path.startsWith('/channel/channels/') && options.method == 'PATCH') {
      final channelId = int.parse(path.split('/')[3]);
      updatedChannels.add((channelId, body));
      return _respond(
        options,
        failUpdateChannel,
        () => _updateChannel(channelId, body),
      );
    }
    if (path == '/project/projects' && options.method == 'POST') {
      return _respond(options, failCreateProject, () => _createProject(body));
    }
    if (path == '/project/projects') {
      final teamId = int.parse(options.uri.queryParameters['teamId']!);
      await projectGates[teamId];
      return _respond(
        options,
        failProjects,
        () => {'content': projects[teamId] ?? const [], 'last': true},
      );
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

  /// 서버처럼 팀 이름 없이 팀 id 만 돌려준다. 모르는 코드는 404.
  Object _join(String code) {
    final team = joinableTeams[code];
    if (team == null) throw const ServerFailure(404, '유효하지 않은 초대 코드입니다.');
    teams.add(team);
    return {
      'teamId': team['id'],
      'userId': 1,
      'role': 'MEMBER',
      'joinedAt': '2026-11-17T03:00:00',
      'nicknameFormatEnforced': false,
      'nicknameFormatExample': null,
    };
  }

  List<Map<String, dynamic>> _membersOf(int teamId) => [
    for (final userId in members[teamId] ?? const <int>[])
      {'id': userId, 'userId': userId, 'role': 'MEMBER', 'nickname': null},
  ];

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

  /// 서버처럼 보낸 필드만 바꾼다.
  Map<String, dynamic> _updateChannel(
    int channelId,
    Map<String, dynamic> body,
  ) {
    final channel = channels.values
        .expand((list) => list)
        .firstWhere((channel) => channel['id'] == channelId);
    channel.addAll(body);
    return channel;
  }

  /// 서버처럼 팀의 마지막 순서에 둔다.
  Map<String, dynamic> _createProject(Map<String, dynamic> body) {
    createdProjects.add(body);
    final teamId = body['teamId'] as int;
    final teamProjects = projects.putIfAbsent(teamId, () => []);
    final project = {
      'id': _nextId++,
      'teamId': teamId,
      'name': body['name'],
      'description': body['description'],
      'status': 'ACTIVE',
      'position': teamProjects.length,
    };
    teamProjects.add(project);
    return project;
  }

  static ResponseBody _respond(
    RequestOptions options,
    ServerFailure? failure,
    Object? Function() data,
  ) {
    if (failure == null) {
      try {
        return _json({
          'status': 'OK',
          'code': 200,
          'message': 'OK',
          'data': data(),
        });
      } on ServerFailure catch (thrown) {
        // 요청 내용에 따라 실패하는 경로(없는 초대 코드 등)는 data 가 던진다.
        return _respond(options, thrown, data);
      }
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

/// [server] 로 요청을 보내는 프로젝트 저장소.
ProjectRepository projectRepositoryOf(FakeChatServer server) =>
    ProjectRepository.withDio(_dioOf(server, 'project'));

/// 가짜 채팅 소켓. 구독한 팀·채널 방을 기록하고, 테스트가 서버 이벤트를 [push] 한다.
class FakeChatSocket implements ChatSocket {
  final _events = StreamController<SocketEvent>.broadcast();

  /// 지금 구독 중인 팀 방.
  final joined = <int>{};

  /// 서버가 [name] 이벤트를 보낸 것처럼 흘린다.
  ///
  /// 실제 [ChatSocket] 은 [ChatSocket.listenedEvents] 에 없는 이벤트를 받지 않는다.
  /// 가짜가 그 목록을 건너뛰면 목록에 빠진 이벤트도 테스트가 통과하므로 똑같이 막는다.
  void push(String name, Map<String, dynamic> data) {
    if (!ChatSocket.listenedEvents.contains(name)) {
      throw ArgumentError.value(name, 'name', 'ChatSocket 이 받지 않는 이벤트');
    }
    _events.add((name: name, data: data));
  }

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
///
/// [notifications] 를 안 주면 알림이 오지 않는 저장소를 둔다.
Widget chatTestApp(
  FakeChatServer server, {
  required Widget home,
  FakeChatSocket? socket,
  NotificationRepository? notifications,
  ThemeData? theme,
}) => MultiRepositoryProvider(
  providers: [
    RepositoryProvider.value(value: teamRepositoryOf(server)),
    RepositoryProvider.value(value: channelRepositoryOf(server)),
    RepositoryProvider.value(value: projectRepositoryOf(server)),
    RepositoryProvider<ChatSocket>.value(value: socket ?? FakeChatSocket()),
    RepositoryProvider.value(
      value: notifications ?? NotificationRepository(FakeNotificationStream()),
    ),
  ],
  child: MaterialApp(theme: theme, home: home),
);
