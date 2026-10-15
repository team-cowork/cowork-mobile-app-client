import 'package:cowork_app/feature/chat/domain/enums/channel_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_server.dart';

void main() {
  test('채널 목록의 viewType 을 앱 유형으로 옮기고, 모르는 값은 일반 채팅으로 본다', () async {
    final server = FakeChatServer(
      channels: {
        1: [
          {'id': 1, 'name': '파일', 'viewType': 'FILE_SHARE'},
          {'id': 2, 'name': '음성', 'viewType': 'VOICE'},
          {'id': 3, 'name': '새 종류', 'viewType': 'WHITEBOARD'},
        ],
      },
    );

    final channels = await chatRepositoryOf(server).fetchChannels(1);

    expect(
      [for (final channel in channels) channel.type],
      [ChannelType.file, ChannelType.voice, ChannelType.chat],
    );
  });

  test('팀 목록을 읽는다', () async {
    final teams = await chatRepositoryOf(FakeChatServer()).fetchMyTeams();

    expect(
      [for (final team in teams) (team.id, team.name)],
      [(1, '코워크'), (2, '디자인팀')],
    );
  });
}
