import 'package:cowork_app/feature/channel/data/model/channel_socket_event.dart';
import 'package:cowork_app/feature/channel/domain/enums/channel_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('channel:created 는 channelId 로 채널을 만들고 viewType 을 앱 유형으로 옮긴다', () {
    final event = ChannelSocketEvent.from((
      name: 'channel:created',
      data: {
        'channelId': 7,
        'teamId': 1,
        'name': '회의',
        'viewType': 'MEETING_NOTE',
      },
    ));

    expect(event, isA<ChannelUpserted>());
    final upserted = event as ChannelUpserted;
    expect(upserted.teamId, 1);
    expect(upserted.channel.id, '7');
    expect(upserted.channel.name, '회의');
    expect(upserted.channel.type, ChannelType.meetingNote);
  });

  test('삭제와 읽기 권한 회수는 모두 채널을 빼는 이벤트다', () {
    for (final name in ['channel:deleted', 'channel:access:revoked']) {
      final event = ChannelSocketEvent.from((
        name: name,
        data: {'channelId': 7},
      ));
      expect((event as ChannelRemoved).channelId, '7');
    }
  });

  test('team:access:revoked 는 팀 id 를 담는다', () {
    final event = ChannelSocketEvent.from((
      name: 'team:access:revoked',
      data: {'teamId': 3},
    ));
    expect((event as TeamAccessRevoked).teamId, 3);
  });

  test('id 가 없거나 모르는 이벤트는 무시한다', () {
    expect(
      ChannelSocketEvent.from((name: 'channel:created', data: {'name': 'x'})),
      isNull,
    );
    expect(
      ChannelSocketEvent.from((name: 'message:new', data: {'channelId': 1})),
      isNull,
    );
  });

  test('이름이나 유형이 빠진 생성·수정은 기존 채널을 덮지 않게 무시한다', () {
    for (final name in ['channel:created', 'channel:updated']) {
      expect(
        ChannelSocketEvent.from((
          name: name,
          data: {'channelId': 7, 'teamId': 1, 'viewType': 'FILE_SHARE'},
        )),
        isNull,
      );
      expect(
        ChannelSocketEvent.from((
          name: name,
          data: {'channelId': 7, 'teamId': 1, 'name': '시안'},
        )),
        isNull,
      );
    }
  });

  test('필드 타입이 다르면 예외 없이 무시한다', () {
    // 던지면 소켓 스트림이 오류로 끊긴다.
    expect(
      ChannelSocketEvent.from((
        name: 'channel:created',
        data: {'channelId': '7', 'teamId': 1, 'name': 'x'},
      )),
      isNull,
    );
  });

  test('channel:updated 의 projectId 를 채널에 싣는다', () {
    final event = ChannelSocketEvent.from((
      name: 'channel:updated',
      data: {
        'channelId': 7,
        'teamId': 1,
        'name': '회의',
        'viewType': 'TEXT',
        'projectId': 5,
      },
    ));

    expect((event as ChannelUpserted).channel.projectId, 5);
  });

  test('project 이벤트는 그 팀의 프로젝트 목록을 다시 읽게 한다', () {
    for (final name in [
      'project:created',
      'project:updated',
      'project:deleted',
    ]) {
      final event = ChannelSocketEvent.from((
        name: name,
        // 생성·수정은 이름·상태 등도 오지만 팀 id 만 쓴다.
        data: {'projectId': 5, 'teamId': 1, 'name': '앱', 'status': 'ACTIVE'},
      ));
      expect((event as ProjectsChanged).teamId, 1);
    }
  });
}
