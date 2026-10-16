import 'package:cowork_app/feature/chat/data/model/requests/create_channel_request.dart';
import 'package:cowork_app/feature/chat/domain/enums/channel_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_server.dart';

void main() {
  test('채널 유형을 서버 type/viewType 짝으로 바꿔 보낸다', () async {
    final server = FakeChatServer();
    final repository = chatRepositoryOf(server);

    for (final type in ChannelType.values) {
      await repository.createChannel(
        CreateChannelRequest.of(
          teamId: 1,
          name: type.name,
          type: type,
          isPrivate: type == ChannelType.voice,
        ),
      );
    }

    expect(
      [for (final body in server.created) (body['type'], body['viewType'])],
      [
        ('TEXT', 'TEXT'),
        ('TEXT', 'WEBHOOK'),
        ('TEXT', 'FILE_SHARE'),
        ('TEXT', 'ACCOUNT_SHARE'),
        ('TEXT', 'MEETING_NOTE'),
        ('VOICE', 'VOICE'),
      ],
    );
    expect(server.created.first, containsPair('teamId', 1));
    expect(server.created.last, containsPair('isPrivate', true));
  });

  test('생성 응답의 채널을 앱 채널로 돌려준다', () async {
    final channel = await chatRepositoryOf(FakeChatServer()).createChannel(
      CreateChannelRequest.of(
        teamId: 1,
        name: '회의',
        type: ChannelType.meetingNote,
        isPrivate: false,
      ),
    );

    expect(channel.id, '100');
    expect(channel.name, '회의');
    expect(channel.type, ChannelType.meetingNote);
  });

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
