import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/channel/presentation/blocs/channel_list/channel_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_server.dart';

/// 첫 팀까지 불러온 Bloc.
Future<ChannelListBloc> _loaded(
  FakeChatServer server, {
  FakeChatSocket? socket,
}) async {
  final bloc = ChannelListBloc(
    teamRepositoryOf(server),
    channelRepositoryOf(server),
    socket ?? FakeChatSocket(),
  )..add(const ChannelListEvent.requested());
  await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelListData>);
  return bloc;
}

ChannelListData _data(ChannelListBloc bloc) =>
    (bloc.state as AsyncSuccess<ChannelListData>).data;

void main() {
  List<int> channelIds(ChannelListBloc bloc) => [
    for (final group in _data(bloc).channelGroups)
      for (final channel in group.channels) int.parse(channel.id),
  ];

  test('소켓이 끊김 복구 없이 다시 붙으면 채널 목록을 다시 읽어 바꾼다', () async {
    final server = FakeChatServer();
    final socket = FakeChatSocket();
    final bloc = await _loaded(server, socket: socket);
    addTearDown(bloc.close);
    expect(channelIds(bloc), [10, 11]);

    // 끊긴 동안 채널 하나가 생기고 하나가 지워졌다.
    server.channels[1] = [
      {'id': 11, 'name': '배포', 'type': 'TEXT', 'viewType': 'WEBHOOK'},
      {'id': 12, 'name': '새 채널', 'type': 'TEXT', 'viewType': 'TEXT'},
    ];
    socket.reconnect();
    await bloc.stream.firstWhere(
      (s) =>
          s is AsyncSuccess<ChannelListData> &&
          s.data.channelGroups.first.channels.any((c) => c.id == '12'),
    );

    expect(channelIds(bloc), [11, 12]);
  });

  test('다시 읽는 동안 화면을 로딩으로 바꾸지 않는다', () async {
    final server = FakeChatServer();
    final socket = FakeChatSocket();
    final bloc = await _loaded(server, socket: socket);
    addTearDown(bloc.close);
    final states = <ChannelListState>[];
    final subscription = bloc.stream.listen(states.add);
    addTearDown(subscription.cancel);

    socket.reconnect();
    await pumpEventQueue();

    expect(states.whereType<AsyncLoading<ChannelListData>>(), isEmpty);
  });

  test('다시 읽기에 실패하면 보던 목록을 그대로 둔다', () async {
    final server = FakeChatServer();
    final socket = FakeChatSocket();
    final bloc = await _loaded(server, socket: socket);
    addTearDown(bloc.close);
    server.failChannels = const ServerFailure(503);

    socket.reconnect();
    await pumpEventQueue();

    expect(bloc.state, isA<AsyncSuccess<ChannelListData>>());
    expect(channelIds(bloc), [10, 11]);
  });

  test('불러온 뒤 새로 들어간 팀을 고르면 팀 목록을 다시 읽어 옮긴다', () async {
    final server = FakeChatServer();
    final bloc = await _loaded(server);
    addTearDown(bloc.close);
    expect(_data(bloc).teamId, 1);

    server.teams.add({
      'id': 3,
      'name': '새 팀',
      'iconUrl': null,
      'myRole': 'MEMBER',
    });
    bloc.add(const ChannelListEvent.teamSelected(3));
    await bloc.stream.firstWhere(
      (s) => s is AsyncSuccess<ChannelListData> && s.data.teamId == 3,
    );

    expect(_data(bloc).workspaceName, '새 팀');
    expect([for (final s in _data(bloc).workspaceShortcuts) s.id], [1, 2, 3]);
  });

  test('다시 읽어도 없는 팀이면 보던 팀에 남는다', () async {
    final server = FakeChatServer();
    final bloc = await _loaded(server);
    addTearDown(bloc.close);

    bloc.add(const ChannelListEvent.teamSelected(99));
    await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelListData>);

    expect(_data(bloc).teamId, 1);
    expect(_data(bloc).workspaceName, '코워크');
  });
}
