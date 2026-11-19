import 'package:cowork_app/core/network/chat_socket.dart';
import 'package:cowork_app/feature/auth/data/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

void main() {
  test('API 주소에서 소켓이 붙을 origin 만 남긴다', () {
    expect(
      socketOriginOf('https://cowork.example.com/api'),
      'https://cowork.example.com',
    );
    expect(
      socketOriginOf('https://cowork.example.com/api/'),
      'https://cowork.example.com',
    );
    expect(socketOriginOf('http://10.0.2.2:8080/api'), 'http://10.0.2.2:8080');
  });

  test('같은 채널 방을 두 번 들어가면 두 번 나가야 방에서 나간다', () {
    // 토큰이 없어 실제 연결은 하지 않고 구독만 센다.
    final socket = ChatSocket(
      AuthRepository(dio: Dio()),
      origin: 'https://example.test',
    );
    addTearDown(socket.dispose);

    socket
      ..joinChannel(10)
      ..joinChannel(10);
    socket.leaveChannel(10);
    expect(socket.joinedChannelIds, [10]);

    socket.leaveChannel(10);
    expect(socket.joinedChannelIds, isEmpty);

    socket.leaveChannel(10);
    expect(socket.joinedChannelIds, isEmpty);
  });

  group('연결된 소켓', () {
    late List<_FakeSocket> created;
    late ChatSocket socket;

    /// 마지막으로 만든 소켓을 서버가 받아 준 것처럼 연결한다.
    _FakeSocket connectLast({bool recovered = false}) =>
        created.last..fireConnect(recovered: recovered);

    setUp(() {
      created = [];
      socket = ChatSocket(
        _TokenAuth(),
        origin: 'https://example.test',
        createSocket: (uri, options) {
          final fake = _FakeSocket();
          created.add(fake);
          return fake;
        },
      );
      addTearDown(socket.dispose);
    });

    test('같은 채널을 두 번 구독해도 join 은 처음 한 번만 보낸다', () {
      socket.joinChannel(10);
      final connection = connectLast();

      socket
        ..joinChannel(10)
        ..joinChannel(11);

      expect(created, hasLength(1));
      expect(connection.emitted, [
        [
          'join',
          {'channelId': 10},
        ],
        [
          'join',
          {'channelId': 11},
        ],
      ]);
    });

    test('팀 방을 나가도 채널 방이 남아 있으면 연결을 유지한다', () {
      socket
        ..joinTeam(1)
        ..joinChannel(10);
      final connection = connectLast();

      socket.leaveTeam(1);

      expect(connection.disposed, isFalse);
    });

    test('채널 방을 나가도 팀 방이 남아 있으면 연결을 유지한다', () {
      socket
        ..joinTeam(1)
        ..joinChannel(10);
      final connection = connectLast();

      socket.leaveChannel(10);

      expect(connection.disposed, isFalse);
    });

    test('남은 방이 없으면 연결을 끊는다', () {
      socket.joinTeam(1);
      final connection = connectLast();

      socket.leaveTeam(1);

      expect(connection.disposed, isTrue);
    });

    test('복구 없이 다시 붙으면 reconnected 로 알린다', () async {
      final reconnects = <void>[];
      socket.reconnected.listen(reconnects.add);
      socket.joinChannel(10);
      final connection = connectLast();

      connection.fireConnect(recovered: false);
      await pumpEventQueue();

      expect(reconnects, hasLength(1));
      // 새 연결이 비어 있으므로 방에 다시 들어간다.
      expect(connection.emitted, [
        [
          'join',
          {'channelId': 10},
        ],
        [
          'join',
          {'channelId': 10},
        ],
      ]);
    });

    test('방을 다 나갔다가 다시 들어오면 첫 연결로 보고 reconnected 를 보내지 않는다', () async {
      final reconnects = <void>[];
      socket.reconnected.listen(reconnects.add);
      socket.joinChannel(10);
      connectLast();
      socket.leaveChannel(10);

      socket.joinChannel(10);
      connectLast();
      await pumpEventQueue();

      expect(created, hasLength(2));
      expect(reconnects, isEmpty);
    });
  });
}

/// 소켓을 열 수 있게 access token 만 준다.
class _TokenAuth extends Fake implements AuthRepository {
  @override
  String? get accessToken => 'token';
}

/// 서버 대신 이벤트를 흘리고, 앱이 보낸 이벤트와 정리 여부를 기록한다.
class _FakeSocket extends Fake implements io.Socket {
  final emitted = <List<Object?>>[];
  final _handlers = <String, List<dynamic Function(dynamic)>>{};
  bool disposed = false;

  @override
  bool connected = false;

  @override
  bool recovered = false;

  @override
  dynamic Function() on(String event, dynamic Function(dynamic) handler) {
    _handlers.putIfAbsent(event, () => []).add(handler);
    return () => _handlers[event]?.remove(handler);
  }

  @override
  void emit(String event, [dynamic data]) => emitted.add([event, data]);

  @override
  io.Socket connect() => this;

  @override
  void dispose() => disposed = true;

  void fireConnect({required bool recovered}) {
    connected = true;
    this.recovered = recovered;
    for (final handler in [...?_handlers['connect']]) {
      handler(null);
    }
  }
}
