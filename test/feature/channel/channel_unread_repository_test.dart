import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_server.dart';

void main() {
  test('팀 안 읽은 수를 chat 서비스에서 읽어 채널 id 별로 돌려준다', () async {
    final server = FakeChatServer()..unread[1] = {10: 3, 11: 0};

    final unread = await channelUnreadRepositoryOf(server).fetchTeamUnread(1);

    expect(unread, {'10': 3, '11': 0});
    expect(server.requests, ['GET /chat/chat/teams/1/unread']);
  });

  test('안 읽은 채널이 없으면 빈 Map 이다', () async {
    final unread = await channelUnreadRepositoryOf(
      FakeChatServer(),
    ).fetchTeamUnread(1);

    expect(unread, isEmpty);
  });

  test('실패하면 던진다', () async {
    final server = FakeChatServer()..failUnread = const ServerFailure(403);

    expect(
      channelUnreadRepositoryOf(server).fetchTeamUnread(1),
      throwsA(isA<DioException>()),
    );
  });
}
