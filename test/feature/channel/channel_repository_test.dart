import 'package:cowork_app/feature/channel/data/model/requests/create_channel_request.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/channel/domain/enums/channel_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_server.dart';

void main() {
  test('채널 유형을 서버 type/viewType 짝으로 바꿔 보낸다', () async {
    final server = FakeChatServer();
    final repository = channelRepositoryOf(server);

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
    final channel = await channelRepositoryOf(FakeChatServer()).createChannel(
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

    final channels = await channelRepositoryOf(server).fetchChannels(1);

    expect(
      [for (final channel in channels) channel.type],
      [ChannelType.file, ChannelType.voice, ChannelType.chat],
    );
  });

  group('프로젝트에 넣기', () {
    final request = CreateChannelRequest.of(
      teamId: 1,
      name: '디자인',
      type: ChannelType.chat,
      isPrivate: false,
    );

    test('projectId 를 주면 만든 뒤 PATCH 로 프로젝트에 넣는다', () async {
      final server = FakeChatServer();

      final channel = await channelRepositoryOf(
        server,
      ).createChannel(request, projectId: 5);

      // 생성 요청에는 projectId 가 없다.
      expect(server.created.single, isNot(contains('projectId')));
      expect(server.requests, [
        'POST /channel/channels',
        'PATCH /channel/channels/${channel.id}',
      ]);
      expect(server.updatedChannels.single.$2, {'projectId': 5});
      expect(channel.projectId, 5);
    });

    test('projectId 가 없으면 PATCH 하지 않는다', () async {
      final server = FakeChatServer();

      await channelRepositoryOf(server).createChannel(request);

      expect(server.requests, ['POST /channel/channels']);
    });

    test('넣다 실패하면 만든 채널을 실어 던진다', () async {
      final server = FakeChatServer()
        ..failUpdateChannel = const ServerFailure(403);

      await expectLater(
        channelRepositoryOf(server).createChannel(request, projectId: 5),
        throwsA(
          isA<ChannelProjectLinkFailure>()
              .having((e) => e.channel.name, 'channel.name', '디자인')
              .having((e) => e.channel.projectId, 'channel.projectId', isNull),
        ),
      );
    });
  });
}
