import 'package:cowork_app/core/network/chat_socket.dart';
import 'package:cowork_app/feature/auth/data/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
