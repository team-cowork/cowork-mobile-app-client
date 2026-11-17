import 'package:flutter_test/flutter_test.dart';

import 'dm_test_server.dart';

void main() {
  test('대화 목록은 서버가 준 순서대로 마지막 메시지와 읽지 않은 수를 담는다', () async {
    final gateway = FakeDmGateway(
      conversations: [
        dmJson(11, 2, content: '두 번째', unreadCount: 3),
        dmJson(12, 3, content: null),
      ],
    );

    final conversations = await dmRepositoryOf(gateway).fetchConversations();

    expect(gateway.calls, ['GET /chat/chat/dms']);
    expect(conversations.map((c) => c.channelId), [11, 12]);
    expect(conversations.first.otherUserId, 2);
    expect(conversations.first.unreadCount, 3);
    expect(conversations.first.lastMessage?.content, '두 번째');
    expect(conversations.last.lastMessage, isNull);
  });

  test('상대를 알 수 없는 대화도 읽는다', () async {
    final gateway = FakeDmGateway(
      conversations: [
        {'channelId': 13, 'otherUserId': null, 'unreadCount': 0},
      ],
    );

    final conversations = await dmRepositoryOf(gateway).fetchConversations();

    expect(conversations.single.otherUserId, isNull);
  });

  test('숨기기는 대화 채널 경로로 DELETE 를 보낸다', () async {
    final gateway = FakeDmGateway();

    await dmRepositoryOf(gateway).hideConversation(11);

    expect(gateway.calls, ['DELETE /chat/chat/dms/11']);
  });

  test('열기는 상대 id 를 보내고 DM 채널 id 를 돌려준다', () async {
    final gateway = FakeDmGateway();

    final channelId = await dmRepositoryOf(gateway).openConversation(2);

    expect(gateway.bodies['POST /channel/dms'], {'targetUserId': 2});
    expect(channelId, 77);
  });
}
