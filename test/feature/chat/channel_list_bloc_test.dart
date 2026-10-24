import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/chat/presentation/blocs/channel_list/channel_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_server.dart';

/// 첫 팀까지 불러온 Bloc.
Future<ChannelListBloc> _loaded(FakeChatServer server) async {
  final bloc = ChannelListBloc(
    teamRepositoryOf(server),
    channelRepositoryOf(server),
    FakeChatSocket(),
  )..add(const ChannelListEvent.requested());
  await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelListData>);
  return bloc;
}

ChannelListData _data(ChannelListBloc bloc) =>
    (bloc.state as AsyncSuccess<ChannelListData>).data;

void main() {
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
