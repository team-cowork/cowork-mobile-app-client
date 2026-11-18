import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/core/network/chat_socket.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/notifications/data/repositories/notification_repository.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:cowork_app/feature/team/data/repositories/team_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../notifications/notification_test_stream.dart';

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
  ServerFailure? failLeave;
  ServerFailure? failPermissions;

  /// 팀 id 별 내(1) 역할의 권한. 없는 팀은 권한이 하나도 없다.
  /// 기본값은 내가 소유자인 코워크(1)만 `administrator` 다.
  final permissions = <int, Map<String, bool>>{
    1: {'administrator': true},
  };

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
    if (path == '/user/users/me') {
      return _respond(options, null, () => {'id': 1, 'name': '나'});
    }
    // `GET /teams/{teamId}/members/1/roles`: 내 역할. 기본 역할 하나에 권한을 싣는다.
    if (path.startsWith('/team/teams/') && path.endsWith('/members/1/roles')) {
      final teamId = int.parse(path.split('/')[3]);
      return _respond(
        options,
        failPermissions,
        () => [
          {
            'id': 1,
            'name': '@everyone',
            'permissions': permissions[teamId] ?? const <String, bool>{},
          },
        ],
      );
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
        // `DELETE /teams/{teamId}/members/{userId}`: 팀 나가기. 서버처럼 내 팀 목록에서 뺀다.
        case ('DELETE', 'members'):
          return _respond(options, failLeave, () {
            teams.removeWhere((team) => team['id'] == teamId);
            return null;
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

/// [server] 로 요청을 보내는 프로필 저장소. 홈이 내 id 를 읽어 팀 권한을 묻는다.
ProfileRepository profileRepositoryOf(FakeChatServer server) =>
    ProfileRepository.withDio(_dioOf(server, 'user'));

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
///
/// [router] 를 주면 [home] 대신 그 라우터로 띄운다. 다른 화면으로 옮겨 가는 테스트용이다.
///
/// [notifications] 를 안 주면 알림이 오지 않는 저장소를 둔다.
Widget chatTestApp(
  FakeChatServer server, {
  Widget? home,
  GoRouter? router,
  FakeChatSocket? socket,
  NotificationRepository? notifications,
  ThemeData? theme,
}) => MultiRepositoryProvider(
  providers: [
    RepositoryProvider.value(value: teamRepositoryOf(server)),
    RepositoryProvider.value(value: channelRepositoryOf(server)),
    RepositoryProvider.value(value: profileRepositoryOf(server)),
    RepositoryProvider<ChatSocket>.value(value: socket ?? FakeChatSocket()),
    RepositoryProvider.value(
      value: notifications ?? NotificationRepository(FakeNotificationStream()),
    ),
  ],
  child: router == null
      ? MaterialApp(theme: theme, home: home)
      : MaterialApp.router(theme: theme, routerConfig: router),
);
