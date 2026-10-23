import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/utils/logger.dart';
import '../feature/auth/data/auth_repository.dart';
import '../feature/auth/data/dgsm_oauth_config.dart';

/// 서버가 소켓으로 보낸 이벤트 하나. [data] 는 이벤트 payload(JSON 객체)다.
typedef SocketEvent = ({String name, Map<String, dynamic> data});

/// cowork-chat socket.io 연결 (`/ws/chat`, namespace `/chat`).
///
/// 채팅 메시지 수신도 같은 연결을 쓰게 되므로 앱에 하나만 두고 화면들이 나눠 쓴다.
/// 구독한 방이 하나라도 있으면 연결하고, 다 나가면 끊는다.
///
/// 인증은 handshake 의 `Authorization` 헤더(게이트웨이가 검증)와 socket.io
/// `auth.token`(게이트웨이를 거치지 않을 때 채팅 서버가 직접 검증)에 같은 access
/// token 을 싣는다. 서버는 handshake 에서 인증하므로 `connect` 는 인증에 성공했다는
/// 뜻이고, 실패하면 `connect` 없이 `connect_error` 만 온다. 토큰이 만료돼 `인증 실패`
/// 로 거절되면 한 번 갱신해 다시 붙는다.
///
/// ponytail: 끊긴 동안(백그라운드 등) 놓친 이벤트는 다시 받지 않는다. 서버의 끊김
/// 복구는 2분까지만 된다.
class ChatSocket {
  ChatSocket(this._auth, {String? origin})
    : _origin = origin ?? socketOriginOf(DgsmOAuthConfig.apiBaseUrl);

  final AuthRepository _auth;

  /// 게이트웨이 origin. (예: `https://cowork.example.com`)
  final String _origin;

  /// 화면에 넘길 서버 이벤트. 받는 이벤트만 [_listened] 에 둔다.
  static const _listened = [
    'channel:created',
    'channel:updated',
    'channel:deleted',
    'channel:access:revoked',
    'team:access:revoked',
  ];

  final _events = StreamController<SocketEvent>.broadcast();

  /// 구독 중인 팀 방. 다시 연결될 때마다 다시 들어간다.
  final _teams = <int>{};

  io.Socket? _socket;

  /// 인증 실패로 갱신을 이미 한 번 시도했는지. 연결에 성공하면 다시 false.
  bool _reauthTried = false;

  Stream<SocketEvent> get events => _events.stream;

  /// [teamId] 팀 방의 이벤트를 받는다. 연결돼 있지 않으면 연결부터 한다.
  void joinTeam(int teamId) {
    if (!_teams.add(teamId)) return;
    final socket = _socket;
    if (socket == null) {
      _connect();
    } else if (socket.connected) {
      socket.emit('join:team', {'teamId': teamId});
    }
  }

  /// [teamId] 팀 방에서 나간다. 남은 방이 없으면 연결을 끊는다.
  void leaveTeam(int teamId) {
    if (!_teams.remove(teamId)) return;
    _socket?.emit('leave:team', {'teamId': teamId});
    if (_teams.isEmpty) _disconnect();
  }

  void dispose() {
    _teams.clear();
    _disconnect();
    _events.close();
  }

  void _connect() {
    final token = _auth.accessToken;
    if (token == null) {
      Logger.e('access token 없이 소켓을 열 수 없습니다', tag: 'Socket');
      return;
    }
    // 앞 연결이 남아 있으면 버린다. 덮어쓰기만 하면 연결이 새고 이벤트가 두 번 온다.
    _disconnect();

    final socket = io.io(
      '$_origin/chat',
      io.OptionBuilder()
          .setPath('/ws/chat')
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setAuth({'token': token})
          // 토큰을 바꿔 다시 만들 때 예전 헤더를 가진 연결을 재사용하지 않게 한다.
          .enableForceNew()
          .disableAutoConnect()
          .build(),
    );

    socket
      ..onConnect((_) {
        _reauthTried = false;
        Logger.d('소켓 연결 (recovered=${socket.recovered})', tag: 'Socket');
        // 끊김 복구가 안 된 새 연결은 방 구독이 비어 있다.
        for (final teamId in _teams) {
          socket.emit('join:team', {'teamId': teamId});
        }
      })
      ..onDisconnect((reason) => Logger.d('소켓 끊김: $reason', tag: 'Socket'))
      ..onConnectError(_onConnectError)
      ..on('exception', (e) => Logger.e('소켓 예외', tag: 'Socket', error: e))
      ..on('error', (e) => Logger.e('소켓 오류', tag: 'Socket', error: e));
    for (final name in _listened) {
      socket.on(name, (data) {
        Logger.d('소켓 이벤트 $name: $data', tag: 'Socket');
        if (data is Map) {
          _events.add((name: name, data: Map<String, dynamic>.from(data)));
        }
      });
    }

    _socket = socket..connect();
  }

  /// 연결하지 못했다. 서버가 인증 실패로 거절했으면 토큰을 갱신해 한 번만 다시 붙는다.
  ///
  /// 서버가 거절한 연결은 라이브러리가 다시 붙지 않는다. 네트워크 문제로 실패한 것은
  /// `인증 실패` 가 아니라 건드리지 않고, 라이브러리가 스스로 다시 붙는다.
  Future<void> _onConnectError(dynamic data) async {
    final message = data is Map ? '${data['message']}' : '$data';
    Logger.e('소켓 연결 실패: $message', tag: 'Socket');
    if (!message.startsWith('인증 실패') || _reauthTried) return;
    _reauthTried = true;

    _disconnect();
    // 갱신을 기다리는 사이 [joinTeam] 이 예전 토큰으로 먼저 연결했을 수 있다.
    // [_connect] 가 그 연결을 버리고 새 토큰으로 다시 만든다.
    if (await _auth.restoreSession() && _teams.isNotEmpty) _connect();
  }

  void _disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}

/// API 주소(`https://host/api`)에서 소켓이 붙을 origin(`https://host`)만 남긴다.
@visibleForTesting
String socketOriginOf(String apiBaseUrl) {
  final uri = Uri.parse(apiBaseUrl);
  return '${uri.scheme}://${uri.authority}';
}
