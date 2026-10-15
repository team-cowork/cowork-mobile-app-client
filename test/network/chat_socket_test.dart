import 'package:cowork_app/network/chat_socket.dart';
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
}
