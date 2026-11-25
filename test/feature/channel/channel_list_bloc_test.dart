import 'dart:async';

import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/channel/presentation/blocs/channel_list/channel_list_bloc.dart';
import 'package:cowork_app/feature/project/data/model/responses/project_summary_response.dart';
import 'package:cowork_app/feature/team/data/model/requests/create_team_request.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_server.dart';

/// [server] 에 붙은 Bloc. 아직 아무것도 읽지 않았다.
///
/// [unreadPollInterval] 은 기본으로 길게 둬, 주기 읽기를 보는 테스트만 짧게 한다.
ChannelListBloc _bloc(
  FakeChatServer server, {
  FakeChatSocket? socket,
  Stream<int> invitedTeams = const Stream.empty(),
  Stream<AppLifecycleState>? lifecycle,
  Duration unreadPollInterval = const Duration(hours: 1),
}) => ChannelListBloc(
  teamRepositoryOf(server),
  channelRepositoryOf(server),
  projectRepositoryOf(server),
  socket ?? FakeChatSocket(),
  profileRepository: profileRepositoryOf(server),
  unreadRepository: channelUnreadRepositoryOf(server),
  invitedTeams: invitedTeams,
  lifecycle: lifecycle,
  unreadPollInterval: unreadPollInterval,
);

/// 첫 팀까지 불러온 Bloc.
Future<ChannelListBloc> _loaded(
  FakeChatServer server, {
  FakeChatSocket? socket,
  Stream<int> invitedTeams = const Stream.empty(),
  Stream<AppLifecycleState>? lifecycle,
  Duration unreadPollInterval = const Duration(hours: 1),
}) async {
  final bloc = _bloc(
    server,
    socket: socket,
    invitedTeams: invitedTeams,
    lifecycle: lifecycle,
    unreadPollInterval: unreadPollInterval,
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

    server.channels[1] = [
      {'id': 12, 'name': '새 채널', 'type': 'TEXT', 'viewType': 'TEXT'},
    ];
    socket.reconnect();
    await bloc.stream.firstWhere(
      (s) =>
          s is AsyncSuccess<ChannelListData> &&
          s.data.channelGroups.first.channels.any((c) => c.id == '12'),
    );

    expect(states.whereType<AsyncLoading<ChannelListData>>(), isEmpty);
  });

  test('다시 읽기에 실패하면 보던 목록을 그대로 둔다', () async {
    final server = FakeChatServer();
    final socket = FakeChatSocket();
    final bloc = await _loaded(server, socket: socket);
    addTearDown(bloc.close);
    server.requests.clear();
    server.failChannels = const ServerFailure(503);

    socket.reconnect();
    await pumpEventQueue();

    // 다시 읽으러 갔다가 실패해도 보던 목록이 남는다.
    expect(server.requests, contains('GET /channel/teams/1/channels'));
    expect(bloc.state, isA<AsyncSuccess<ChannelListData>>());
    expect(channelIds(bloc), [10, 11]);
  });

  test('다시 읽는 사이 지워진 채널은 먼저 찍힌 응답에 다시 살아나지 않는다', () async {
    final server = FakeChatServer();
    final socket = FakeChatSocket();
    final bloc = await _loaded(server, socket: socket);
    addTearDown(bloc.close);
    final gate = Completer<void>();
    server.channelGates[1] = gate.future;

    socket.reconnect();
    await pumpEventQueue();
    // 응답을 기다리는 사이 10 번 채널이 지워졌다. 응답에는 아직 10 번이 들어 있다.
    socket.push('channel:deleted', {'channelId': 10, 'teamId': 1});
    await pumpEventQueue();
    gate.complete();
    await pumpEventQueue();

    expect(channelIds(bloc), [11]);
  });

  test('다시 읽는 사이 다른 팀으로 옮기면 늦게 온 응답은 버린다', () async {
    final server = FakeChatServer();
    final socket = FakeChatSocket();
    final bloc = await _loaded(server, socket: socket);
    addTearDown(bloc.close);
    final gate = Completer<void>();
    server.channelGates[1] = gate.future;

    socket.reconnect();
    await pumpEventQueue();
    bloc.add(const ChannelListEvent.teamSelected(2));
    await bloc.stream.firstWhere(
      (s) => s is AsyncSuccess<ChannelListData> && s.data.teamId == 2,
    );
    gate.complete();
    await pumpEventQueue();

    expect(_data(bloc).teamId, 2);
  });

  test('끊긴 동안 보던 팀에서 빠졌으면 다른 팀으로 옮긴다', () async {
    final server = FakeChatServer();
    final socket = FakeChatSocket();
    final bloc = await _loaded(server, socket: socket);
    addTearDown(bloc.close);
    expect(_data(bloc).teamId, 1);

    server.teams.removeWhere((team) => team['id'] == 1);
    socket.reconnect();
    await bloc.stream.firstWhere(
      (s) => s is AsyncSuccess<ChannelListData> && s.data.teamId == 2,
    );

    expect([for (final s in _data(bloc).workspaceShortcuts) s.id], [2]);
  });

  test('다시 읽을 때 새로 초대된 팀도 단축 바에 들어온다', () async {
    final server = FakeChatServer();
    final socket = FakeChatSocket();
    final bloc = await _loaded(server, socket: socket);
    addTearDown(bloc.close);

    server.teams.add({
      'id': 3,
      'name': '새 팀',
      'iconUrl': null,
      'myRole': 'MEMBER',
    });
    socket.reconnect();
    await bloc.stream.firstWhere(
      (s) =>
          s is AsyncSuccess<ChannelListData> &&
          s.data.workspaceShortcuts.any((shortcut) => shortcut.id == 3),
    );

    expect(_data(bloc).teamId, 1);
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

  test('내 역할로 보던 팀의 소유자인지 알린다', () async {
    final server = FakeChatServer();
    final bloc = await _loaded(server);
    addTearDown(bloc.close);
    expect(_data(bloc).isTeamOwner, isTrue);

    bloc.add(const ChannelListEvent.teamSelected(2));
    await bloc.stream.firstWhere(
      (s) => s is AsyncSuccess<ChannelListData> && s.data.teamId == 2,
    );

    expect(_data(bloc).isTeamOwner, isFalse);
  });

  List<int> shortcutIds(ChannelListBloc bloc) => [
    for (final shortcut in _data(bloc).workspaceShortcuts) shortcut.id,
  ];

  test('새로 만든 팀은 생성 응답에 역할이 없어도 내가 소유자이고, 있던 팀은 단축 바에 남는다', () async {
    final server = FakeChatServer();
    final bloc = await _loaded(server);
    addTearDown(bloc.close);
    final team = await teamRepositoryOf(
      server,
    ).createTeam(const CreateTeamRequest(name: '새 팀'));

    bloc.add(ChannelListEvent.teamCreated(team));
    await bloc.stream.firstWhere(
      (s) => s is AsyncSuccess<ChannelListData> && s.data.teamId == team.id,
    );

    expect(_data(bloc).isTeamOwner, isTrue);
    expect(shortcutIds(bloc), [1, 2, team.id]);
  });

  test('단축 바는 보고 있는 팀만 선택된 것으로 보인다', () async {
    final server = FakeChatServer();
    final bloc = await _loaded(server);
    addTearDown(bloc.close);

    final selected = [
      for (final shortcut in _data(bloc).workspaceShortcuts)
        if (shortcut.isSelected) shortcut.id,
    ];
    expect(selected, [1]);
  });

  group('다른 사람이 나를 팀에 넣으면', () {
    Map<String, dynamic> team(int id, String name) => {
      'id': id,
      'name': name,
      'iconUrl': null,
      'myRole': 'MEMBER',
    };

    test('보던 팀이 있으면 화면은 두고 단축 바에만 붙인다', () async {
      final server = FakeChatServer();
      final invites = StreamController<int>();
      addTearDown(invites.close);
      final bloc = await _loaded(server, invitedTeams: invites.stream);
      addTearDown(bloc.close);

      server.teams.add(team(3, '새 팀'));
      invites.add(3);
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<ChannelListData> &&
            s.data.workspaceShortcuts.any((shortcut) => shortcut.id == 3),
      );

      expect(_data(bloc).teamId, 1);
      expect(shortcutIds(bloc), [1, 2, 3]);
    });

    test('읽은 팀 목록에 보던 팀이 없으면 낡은 응답으로 보고 버린다', () async {
      final server = FakeChatServer();
      final invites = StreamController<int>();
      addTearDown(invites.close);
      final bloc = await _loaded(server, invitedTeams: invites.stream);
      addTearDown(bloc.close);

      server.teams
        ..removeWhere((t) => t['id'] == 1)
        ..add(team(3, '새 팀'));
      invites.add(3);
      await pumpEventQueue();

      expect(_data(bloc).teamId, 1);
      expect(shortcutIds(bloc), [1, 2]);
    });

    test('팀이 없던 홈이면 초대받은 팀으로 들어간다', () async {
      final server = FakeChatServer(teams: []);
      final invites = StreamController<int>();
      addTearDown(invites.close);
      final bloc = await _loaded(server, invitedTeams: invites.stream);
      addTearDown(bloc.close);
      expect(_data(bloc).teamId, isNull);

      // 초대받은 팀이 목록의 첫 팀이 아니어도 그 팀으로 들어간다.
      server.teams.addAll([team(1, '코워크'), team(2, '디자인팀')]);
      invites.add(2);
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelListData> && s.data.teamId != null,
      );

      expect(_data(bloc).teamId, 2);
    });
  });

  group('팀에서 내 권한', () {
    /// 디자인팀(2, 내가 멤버)으로 옮긴 Bloc.
    Future<ChannelListBloc> onMemberTeam(FakeChatServer server) async {
      final bloc = await _loaded(server);
      bloc.add(const ChannelListEvent.teamSelected(2));
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelListData> && s.data.teamId == 2,
      );
      return bloc;
    }

    test('소유자인 팀은 역할을 읽지 않고 멤버 초대를 보인다', () async {
      final server = FakeChatServer()..permissions.clear();
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      expect(_data(bloc).canInviteMembers, isTrue);
      expect(server.requests, isNot(contains(endsWith('/roles'))));
    });

    test('멤버인 팀은 역할을 읽어 초대 권한이 없으면 멤버 초대를 숨긴다', () async {
      final server = FakeChatServer();
      final bloc = await onMemberTeam(server);
      addTearDown(bloc.close);

      expect(server.requests, contains('GET /team/teams/2/members/1/roles'));
      expect(_data(bloc).canInviteMembers, isFalse);
    });

    test('멤버여도 manage_invites 가 켜진 역할이 있으면 초대할 수 있다', () async {
      final server = FakeChatServer()
        ..permissions[2] = {'manage_invites': true};
      final bloc = await onMemberTeam(server);
      addTearDown(bloc.close);

      expect(_data(bloc).canInviteMembers, isTrue);
    });

    test('멤버인 팀은 채널·프로젝트 생성 권한을 역할로 정한다', () async {
      final noRole = await onMemberTeam(FakeChatServer());
      addTearDown(noRole.close);
      expect(_data(noRole).canCreateChannels, isFalse);
      expect(_data(noRole).canCreateProjects, isFalse);

      final withRole = await onMemberTeam(
        FakeChatServer()
          ..permissions[2] = {'manage_channels': true, 'manage_projects': true},
      );
      addTearDown(withRole.close);
      expect(_data(withRole).canCreateChannels, isTrue);
      expect(_data(withRole).canCreateProjects, isTrue);
    });

    test('소유자인 팀은 채널·프로젝트를 만들 수 있다', () async {
      final bloc = await _loaded(FakeChatServer()..permissions.clear());
      addTearDown(bloc.close);

      expect(_data(bloc).canCreateChannels, isTrue);
      expect(_data(bloc).canCreateProjects, isTrue);
    });

    test('권한을 못 읽어도 홈은 보이고 멤버 초대는 숨기지 않는다', () async {
      final server = FakeChatServer()
        ..failPermissions = const ServerFailure(503);
      final bloc = await onMemberTeam(server);
      addTearDown(bloc.close);

      expect(channelIds(bloc), [20]);
      expect(_data(bloc).canInviteMembers, isTrue);
      expect(_data(bloc).canCreateChannels, isTrue);
      expect(_data(bloc).canCreateProjects, isTrue);
    });
  });

  test('팀에서 나가면 남은 팀으로 옮기고 단축 바에서 뺀다', () async {
    final server = FakeChatServer();
    final socket = FakeChatSocket();
    final bloc = await _loaded(server, socket: socket);
    addTearDown(bloc.close);

    bloc.add(const ChannelListEvent.teamLeft(1));
    await bloc.stream.firstWhere(
      (s) => s is AsyncSuccess<ChannelListData> && s.data.teamId == 2,
    );

    expect([for (final s in _data(bloc).workspaceShortcuts) s.id], [2]);
    expect(socket.joined, {2});
  });

  group('팀 설정에서 돌아오면', () {
    test('팀 목록만 다시 읽어 바뀐 이름을 보이고 채널은 다시 읽지 않는다', () async {
      final server = FakeChatServer();
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      final states = <ChannelListState>[];
      final subscription = bloc.stream.listen(states.add);
      addTearDown(subscription.cancel);
      server.requests.clear();
      server.teams.first['name'] = '새 이름';

      bloc.add(const ChannelListEvent.teamsRefreshed());
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<ChannelListData> &&
            s.data.workspaceName == '새 이름',
      );

      expect(server.requests, ['GET /team/teams']);
      expect(channelIds(bloc), [10, 11]);
      expect(states.whereType<AsyncLoading<ChannelListData>>(), isEmpty);
    });

    test('보던 팀이 없어졌으면 남은 팀으로 옮긴다', () async {
      final server = FakeChatServer();
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      server.teams.removeWhere((team) => team['id'] == 1);

      bloc.add(const ChannelListEvent.teamsRefreshed());
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelListData> && s.data.teamId == 2,
      );

      expect([for (final s in _data(bloc).workspaceShortcuts) s.id], [2]);
    });

    test('다시 읽기에 실패하면 보던 화면을 그대로 둔다', () async {
      final server = FakeChatServer();
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      server.failTeams = const ServerFailure(503);

      bloc.add(const ChannelListEvent.teamsRefreshed());
      await pumpEventQueue();

      expect(bloc.state, isA<AsyncSuccess<ChannelListData>>());
      expect(_data(bloc).workspaceName, '코워크');
    });
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
  group('프로젝트별 묶기', () {
    /// 그룹 이름 → 그 그룹 채널 id.
    Map<String, List<int>> groupsOf(ChannelListBloc bloc) => {
      for (final group in _data(bloc).channelGroups)
        group.name: [
          for (final channel in group.channels) int.parse(channel.id),
        ],
    };

    FakeChatServer serverWithProjects() =>
        FakeChatServer(
            channels: {
              1: [
                {'id': 10, 'name': '일반', 'viewType': 'TEXT', 'projectId': null},
                {'id': 11, 'name': '배포', 'viewType': 'WEBHOOK', 'projectId': 6},
                {'id': 12, 'name': '기획', 'viewType': 'TEXT', 'projectId': 5},
                // 볼 수 없는 프로젝트의 채널.
                {'id': 13, 'name': '비밀', 'viewType': 'TEXT', 'projectId': 99},
              ],
            },
          )
          ..projects[1] = [
            {'id': 5, 'name': '앱'},
            {'id': 6, 'name': '서버'},
            {'id': 7, 'name': '빈 프로젝트'},
          ];

    test('프로젝트 순서대로 묶고, 프로젝트 밖 채널은 맨 끝 채널 그룹에 둔다', () async {
      final bloc = await _loaded(serverWithProjects());
      addTearDown(bloc.close);

      expect(groupsOf(bloc), {
        '앱': [12],
        '서버': [11],
        '빈 프로젝트': <int>[],
        '채널': [10, 13],
      });
      expect(
        [for (final group in _data(bloc).channelGroups) group.projectId],
        [5, 6, 7, null],
      );
    });

    test('프로젝트 목록만 실패하면 홈은 그대로 열고 채널을 한 그룹에 둔다', () async {
      final server = serverWithProjects()
        ..failProjects = const ServerFailure(503);
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      expect(groupsOf(bloc), {
        '채널': [10, 11, 12, 13],
      });
    });

    test('보던 팀의 project 이벤트가 오면 프로젝트 목록만 다시 읽는다', () async {
      final server = serverWithProjects();
      final socket = FakeChatSocket();
      final bloc = await _loaded(server, socket: socket);
      addTearDown(bloc.close);
      server.requests.clear();

      server.projects[1]!.insert(0, {'id': 8, 'name': '새 프로젝트'});
      socket.push('project:created', {'projectId': 8, 'teamId': 1});
      await pumpEventQueue();

      expect(server.requests, ['GET /project/projects']);
      expect(groupsOf(bloc).keys, ['새 프로젝트', '앱', '서버', '빈 프로젝트', '채널']);
    });

    test('다른 팀의 project 이벤트는 읽지 않는다', () async {
      final server = serverWithProjects();
      final socket = FakeChatSocket();
      final bloc = await _loaded(server, socket: socket);
      addTearDown(bloc.close);
      server.requests.clear();

      socket.push('project:deleted', {'projectId': 50, 'teamId': 2});
      await pumpEventQueue();

      expect(server.requests, isEmpty);
    });

    test('지워진 프로젝트의 채널은 채널 그룹으로 옮긴다', () async {
      final server = serverWithProjects();
      final socket = FakeChatSocket();
      final bloc = await _loaded(server, socket: socket);
      addTearDown(bloc.close);

      server.projects[1]!.removeWhere((project) => project['id'] == 5);
      socket.push('project:deleted', {'projectId': 5, 'teamId': 1});
      await pumpEventQueue();

      expect(groupsOf(bloc), {
        '서버': [11],
        '빈 프로젝트': <int>[],
        '채널': [10, 12, 13],
      });
    });

    test('channel:updated 의 projectId 로 채널을 다른 그룹으로 옮긴다', () async {
      final socket = FakeChatSocket();
      final bloc = await _loaded(serverWithProjects(), socket: socket);
      addTearDown(bloc.close);

      socket.push('channel:updated', {
        'channelId': 10,
        'teamId': 1,
        'name': '일반',
        'viewType': 'TEXT',
        'projectId': 7,
      });
      await pumpEventQueue();

      expect(groupsOf(bloc)['빈 프로젝트'], [10]);
      expect(groupsOf(bloc)['채널'], [13]);
    });

    test('채널 목록을 읽는 동안 온 project 이벤트도 놓치지 않는다', () async {
      final server = serverWithProjects();
      final socket = FakeChatSocket();
      final gate = Completer<void>();
      server.channelGates[1] = gate.future;
      final bloc = _bloc(server, socket: socket)
        ..add(const ChannelListEvent.requested());
      addTearDown(bloc.close);
      await pumpEventQueue();

      // 같이 읽은 프로젝트 목록은 이미 왔고, 그 뒤 프로젝트가 생겼다.
      server.projects[1]!.add({'id': 8, 'name': '늦은 프로젝트'});
      socket.push('project:created', {'projectId': 8, 'teamId': 1});
      await pumpEventQueue();
      gate.complete();
      await pumpEventQueue();

      expect(groupsOf(bloc).keys, contains('늦은 프로젝트'));
    });

    test('만든 프로젝트는 다시 읽지 않고 빈 그룹으로 붙인다', () async {
      final server = serverWithProjects();
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      server.requests.clear();

      bloc.add(
        const ChannelListEvent.projectAdded(
          ProjectSummaryResponse(id: 9, name: '마케팅'),
        ),
      );
      await pumpEventQueue();

      expect(server.requests, isEmpty);
      expect(groupsOf(bloc).keys, ['앱', '서버', '빈 프로젝트', '마케팅', '채널']);
    });

    test('재연결 후 프로젝트를 기다리는 사이 다른 팀으로 옮기면 옛 팀 화면을 내보내지 않는다', () async {
      final server = serverWithProjects();
      final socket = FakeChatSocket();
      final bloc = await _loaded(server, socket: socket);
      addTearDown(bloc.close);
      final projectsGate = Completer<void>();
      server.projectGates[1] = projectsGate.future;
      server.channelGates[2] = Completer<void>().future;

      socket.reconnect();
      await pumpEventQueue();
      // 재연결 읽기는 채널을 받고 프로젝트를 기다린다. 그 사이 2 번 팀을 고른다.
      bloc.add(const ChannelListEvent.teamSelected(2));
      await pumpEventQueue();
      projectsGate.complete();
      await pumpEventQueue();

      // 2 번 팀 채널은 아직 오지 않았으니 로딩이어야 한다.
      expect(bloc.state, isA<AsyncLoading<ChannelListData>>());
    });

    test('재연결 후 프로젝트를 기다리는 사이 온 채널 변경을 응답으로 덮지 않는다', () async {
      final server = serverWithProjects();
      final socket = FakeChatSocket();
      final bloc = await _loaded(server, socket: socket);
      addTearDown(bloc.close);
      final projectsGate = Completer<void>();
      server.projectGates[1] = projectsGate.future;

      socket.reconnect();
      await pumpEventQueue();
      // 응답의 채널 목록에는 아직 10 번이 있다.
      socket.push('channel:deleted', {'channelId': 10, 'teamId': 1});
      await pumpEventQueue();
      projectsGate.complete();
      await pumpEventQueue();

      expect(groupsOf(bloc)['채널'], [13]);
    });

    test('재연결하면 프로젝트 목록도 다시 읽는다', () async {
      final server = serverWithProjects();
      final socket = FakeChatSocket();
      final bloc = await _loaded(server, socket: socket);
      addTearDown(bloc.close);

      server.projects[1] = [
        {'id': 6, 'name': '서버'},
      ];
      socket.reconnect();
      await pumpEventQueue();

      expect(groupsOf(bloc).keys, ['서버', '채널']);
    });
  });

  group('안 읽은 수', () {
    Map<String, int> unreadOf(ChannelListBloc bloc) => _data(bloc).unreadCounts;

    int unreadRequests(FakeChatServer server, int teamId) => server.requests
        .where((r) => r == 'GET /chat/chat/teams/$teamId/unread')
        .length;

    FakeChatServer serverWithUnread() => FakeChatServer()
      ..unread[1] = {10: 3}
      ..unread[2] = {20: 7};

    test('채널 목록과 함께 읽어 채널 id 별로 싣는다', () async {
      final bloc = await _loaded(serverWithUnread());
      addTearDown(bloc.close);

      expect(unreadOf(bloc), {'10': 3});
    });

    test('안 읽은 수만 실패하면 홈은 그대로 열고 숫자 없이 보인다', () async {
      final server = serverWithUnread()..failUnread = const ServerFailure(500);
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      expect(channelIds(bloc), [10, 11]);
      expect(unreadOf(bloc), isEmpty);
    });

    test('channel:unread:updated 가 오면 그 채널 숫자만 바꾼다', () async {
      final server = serverWithUnread()..unread[1] = {10: 3, 11: 1};
      final socket = FakeChatSocket();
      final bloc = await _loaded(server, socket: socket);
      addTearDown(bloc.close);

      socket.push('channel:unread:updated', {
        'channelId': 10,
        'unreadCount': 0,
      });
      await pumpEventQueue();

      expect(unreadOf(bloc), {'10': 0, '11': 1});
    });

    test('channel:updated 로 채널이 통째로 바뀌어도 숫자는 남는다', () async {
      final socket = FakeChatSocket();
      final bloc = await _loaded(serverWithUnread(), socket: socket);
      addTearDown(bloc.close);

      socket.push('channel:updated', {
        'channelId': 10,
        'teamId': 1,
        'name': '새 이름',
        'viewType': 'TEXT',
      });
      await pumpEventQueue();

      expect(_data(bloc).channelGroups.last.channels.first.name, '새 이름');
      expect(unreadOf(bloc), {'10': 3});
    });

    test('형식이 맞지 않는 channel:unread:updated 는 버린다', () async {
      final socket = FakeChatSocket();
      final bloc = await _loaded(serverWithUnread(), socket: socket);
      addTearDown(bloc.close);

      socket.push('channel:unread:updated', {'channelId': 10});
      socket.push('channel:unread:updated', {
        'channelId': '10',
        'unreadCount': 0,
      });
      await pumpEventQueue();

      expect(unreadOf(bloc), {'10': 3});
    });

    test('채널 목록을 읽는 동안 온 숫자도 목록을 받은 뒤 반영한다', () async {
      final server = serverWithUnread();
      final socket = FakeChatSocket();
      final gate = Completer<void>();
      server.channelGates[1] = gate.future;
      final bloc = _bloc(server, socket: socket)
        ..add(const ChannelListEvent.requested());
      addTearDown(bloc.close);
      await pumpEventQueue();

      // 같이 읽은 안 읽은 수(3)는 이미 왔고, 그 뒤 읽음 처리됐다.
      socket.push('channel:unread:updated', {
        'channelId': 10,
        'unreadCount': 0,
      });
      await pumpEventQueue();
      gate.complete();
      await bloc.stream.firstWhere((s) => s is AsyncSuccess<ChannelListData>);
      await pumpEventQueue();

      expect(unreadOf(bloc), {'10': 0});
    });

    test('팀을 바꾸면 이전 팀 숫자를 버리고 새 팀 숫자를 읽는다', () async {
      final bloc = await _loaded(serverWithUnread());
      addTearDown(bloc.close);

      bloc.add(const ChannelListEvent.teamSelected(2));
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelListData> && s.data.teamId == 2,
      );

      expect(unreadOf(bloc), {'20': 7});
    });

    test('재연결하면 안 읽은 수도 다시 읽는다', () async {
      final server = serverWithUnread();
      final socket = FakeChatSocket();
      final bloc = await _loaded(server, socket: socket);
      addTearDown(bloc.close);

      server.unread[1] = {10: 5};
      socket.reconnect();
      await pumpEventQueue();

      expect(unreadOf(bloc), {'10': 5});
    });

    test('주기마다 다시 읽는다', () async {
      final server = serverWithUnread();
      final bloc = await _loaded(
        server,
        unreadPollInterval: const Duration(milliseconds: 10),
      );
      addTearDown(bloc.close);

      // 다른 사람이 메시지를 보냈다. 서버는 이 변화를 소켓으로 알리지 않는다.
      server.unread[1] = {10: 4};
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<ChannelListData> &&
            s.data.unreadCounts['10'] == 4,
      );
    });

    test('숫자가 그대로면 다시 읽어도 화면을 다시 내보내지 않는다', () async {
      final server = serverWithUnread();
      final bloc = await _loaded(
        server,
        unreadPollInterval: const Duration(milliseconds: 5),
      );
      addTearDown(bloc.close);
      final states = <ChannelListState>[];
      final subscription = bloc.stream.listen(states.add);
      addTearDown(subscription.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(unreadRequests(server, 1), greaterThan(2));
      expect(states, isEmpty);
    });

    test('홈이 가려지면 다시 읽지 않고, 다시 보이면 바로 한 번 읽는다', () async {
      final server = serverWithUnread();
      final bloc = await _loaded(
        server,
        unreadPollInterval: const Duration(milliseconds: 10),
      );
      addTearDown(bloc.close);

      bloc.add(const ChannelListEvent.visibilityChanged(visible: false));
      await pumpEventQueue();
      final whileHidden = unreadRequests(server, 1);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(unreadRequests(server, 1), whileHidden);

      server.unread[1] = {10: 0};
      bloc.add(const ChannelListEvent.visibilityChanged(visible: true));
      await pumpEventQueue();

      expect(unreadOf(bloc), {'10': 0});
    });

    test('보이는 중에 다시 보인다고 알려도 바로 읽지 않는다', () async {
      final server = serverWithUnread();
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      bloc.add(const ChannelListEvent.visibilityChanged(visible: true));
      await pumpEventQueue();

      expect(unreadRequests(server, 1), 1);
    });

    test('앱이 뒤로 가면 멈추고, 앞으로 오면 바로 한 번 읽는다', () async {
      final server = serverWithUnread();
      final lifecycle = StreamController<AppLifecycleState>();
      addTearDown(lifecycle.close);
      final bloc = await _loaded(
        server,
        lifecycle: lifecycle.stream,
        unreadPollInterval: const Duration(milliseconds: 10),
      );
      addTearDown(bloc.close);

      lifecycle.add(AppLifecycleState.paused);
      await pumpEventQueue();
      final whilePaused = unreadRequests(server, 1);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(unreadRequests(server, 1), whilePaused);

      server.unread[1] = {10: 9};
      lifecycle.add(AppLifecycleState.resumed);
      await pumpEventQueue();

      expect(unreadOf(bloc), {'10': 9});
    });

    test('다시 읽는 사이 소켓으로 온 숫자는 늦게 온 응답에 덮이지 않는다', () async {
      final server = serverWithUnread();
      final socket = FakeChatSocket();
      final bloc = await _loaded(server, socket: socket);
      addTearDown(bloc.close);

      final gate = Completer<void>();
      server.unreadGate = gate.future;
      bloc.add(const ChannelListEvent.visibilityChanged(visible: false));
      bloc.add(const ChannelListEvent.visibilityChanged(visible: true));
      await pumpEventQueue();

      // 읽기를 시작한 뒤 읽음 처리됐다. 응답은 그 전 값(3)이다.
      socket.push('channel:unread:updated', {
        'channelId': 10,
        'unreadCount': 0,
      });
      await pumpEventQueue();
      gate.complete();
      await pumpEventQueue();

      expect(unreadOf(bloc), {'10': 0});
    });

    test('다시 읽는 사이 다른 팀으로 옮기면 늦게 온 응답은 버린다', () async {
      final server = serverWithUnread();
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      final gate = Completer<void>();
      server.unreadGate = gate.future;
      bloc.add(const ChannelListEvent.visibilityChanged(visible: false));
      bloc.add(const ChannelListEvent.visibilityChanged(visible: true));
      await pumpEventQueue();
      bloc.add(const ChannelListEvent.teamSelected(2));
      await pumpEventQueue();
      gate.complete();
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<ChannelListData> && s.data.teamId == 2,
      );
      await pumpEventQueue();

      expect(unreadOf(bloc), {'20': 7});
    });

    test('같은 숫자가 소켓으로 다시 오면 화면을 다시 내보내지 않는다', () async {
      final socket = FakeChatSocket();
      final bloc = await _loaded(serverWithUnread(), socket: socket);
      addTearDown(bloc.close);
      final states = <ChannelListState>[];
      final subscription = bloc.stream.listen(states.add);
      addTearDown(subscription.cancel);

      // 내가 메시지를 보내면 서버가 같은 숫자로 다시 보낸다.
      socket.push('channel:unread:updated', {
        'channelId': 10,
        'unreadCount': 3,
      });
      await pumpEventQueue();

      expect(states, isEmpty);
    });

    test('닫는 사이 다시 보인다는 이벤트가 와도 타이머를 남기지 않는다', () async {
      final bloc = await _loaded(
        serverWithUnread(),
        unreadPollInterval: const Duration(milliseconds: 10),
      );
      bloc.add(const ChannelListEvent.visibilityChanged(visible: false));
      await pumpEventQueue();

      // 홈이 닫히는 순간 다시 보인다는 알림이 겹쳤다.
      bloc.add(const ChannelListEvent.visibilityChanged(visible: true));
      await bloc.close();

      // 남은 타이머가 닫힌 Bloc 에 이벤트를 넣으면 StateError 로 테스트가 실패한다.
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
  });
}
