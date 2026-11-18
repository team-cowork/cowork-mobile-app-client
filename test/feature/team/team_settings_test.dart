import 'dart:async';
import 'dart:io';

import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/profile/data/profile_store.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:cowork_app/feature/team/data/model/requests/update_team_request.dart';
import 'package:cowork_app/feature/team/data/model/responses/team_response.dart';
import 'package:cowork_app/feature/team/data/model/responses/team_role_response.dart';
import 'package:cowork_app/feature/team/data/model/team_role_mapping.dart';
import 'package:cowork_app/feature/team/data/repositories/team_repository.dart';
import 'package:cowork_app/feature/team/domain/enums/team_permission.dart';
import 'package:cowork_app/feature/team/presentation/blocs/team_settings/team_settings_bloc.dart';
import 'package:cowork_app/feature/team/presentation/views/team_settings_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'team_test_server.dart';

/// 관리·삭제 권한이 모두 있는 역할.
final _admin = roleJson(id: 2, permissions: {'administrator': true});

TeamSettingsBloc _bloc(FakeTeamServer server) => TeamSettingsBloc(
  teamId: 1,
  teamRepository: teamRepositoryOfTeamServer(server),
  profileRepository: profileRepositoryOfTeamServer(server),
);

/// 불러오기까지 마친 Bloc. 이후 요청만 보도록 불러오기 기록은 비운다.
Future<TeamSettingsBloc> _loaded(FakeTeamServer server) async {
  final bloc = _bloc(server)..add(const TeamSettingsEvent.requested());
  await bloc.stream.firstWhere(
    (s) => s is AsyncSuccess<TeamSettingsData> || s is AsyncFailure,
  );
  server.calls.clear();
  return bloc;
}

TeamSettingsData _data(TeamSettingsBloc bloc) =>
    (bloc.state as AsyncSuccess<TeamSettingsData>).data;

/// 업로드할 사진 파일. 테스트가 끝나면 지운다.
String _iconFile(String name) {
  final dir = Directory.systemTemp.createTempSync('team_icon_test');
  addTearDown(() => dir.deleteSync(recursive: true));
  return (File('${dir.path}/$name')..writeAsBytesSync([1, 2, 3, 4])).path;
}

void main() {
  setUp(() => ProfileStore.instance.currentUserId = 1);
  tearDown(() => ProfileStore.instance.currentUserId = null);

  group('저장소', () {
    test('팀 상세를 읽는다', () async {
      final team = await teamRepositoryOfTeamServer(
        FakeTeamServer(),
      ).fetchTeam(1);

      expect(team.name, '코워크');
      expect(team.description, '협업 서비스');
      expect(team.iconUrl, 'https://cdn.test/team-icons/old.png');
    });

    test('팀 수정은 바꾼 필드만 보낸다', () async {
      final server = FakeTeamServer();

      final team = await teamRepositoryOfTeamServer(
        server,
      ).updateTeam(1, const UpdateTeamRequest(description: ''));

      expect(server.bodies['PATCH /team/teams/1'], {'description': ''});
      expect(team.name, '코워크');
      expect(team.description, '');
    });

    test('아이콘은 presigned 발급 → 업로드 → 확인 → 팀에 연결 순서로 바꾼다', () async {
      final server = FakeTeamServer();

      final iconUrl = await teamRepositoryOfTeamServer(
        server,
      ).uploadTeamIcon(1, _iconFile('icon.png'));

      expect(server.calls, [
        'POST /team/teams/icon/presigned',
        'PUT storage/team-icon-uploads/1/new.png',
        'POST /team/teams/icon/confirm',
        'PATCH /team/teams/1/icon',
      ]);
      // presigned 서명에 들어간 형식과 실제 업로드 형식이 같아야 한다.
      expect(server.bodies['POST /team/teams/icon/presigned'], {
        'contentType': 'image/png',
      });
      expect(server.uploadedContentType, 'image/png');
      expect(server.bodies['PUT storage/team-icon-uploads/1/new.png'], 4);
      expect(server.bodies['POST /team/teams/icon/confirm'], {
        'objectKey': 'team-icon-uploads/1/new.png',
      });
      expect(server.bodies['PATCH /team/teams/1/icon'], {
        'iconUrl': FakeTeamServer.uploadedIconUrl,
      });
      expect(iconUrl, FakeTeamServer.uploadedIconUrl);
    });

    test('확장자를 모르면 jpeg 로 올린다', () async {
      final server = FakeTeamServer();

      await teamRepositoryOfTeamServer(
        server,
      ).uploadTeamIcon(1, _iconFile('icon'));

      expect(server.uploadedContentType, 'image/jpeg');
    });

    test('받을 수 있는 형식인지는 거르지 않고 서버에 맡긴다', () async {
      final server = FakeTeamServer();

      await teamRepositoryOfTeamServer(
        server,
      ).uploadTeamIcon(1, _iconFile('icon.heic'));

      expect(server.bodies['POST /team/teams/icon/presigned'], {
        'contentType': 'image/heic',
      });
    });

    test('팀 나가기는 내 멤버 기록을, 팀 삭제는 팀을 지운다', () async {
      final server = FakeTeamServer();
      final repository = teamRepositoryOfTeamServer(server);

      await repository.leaveTeam(1, 1);
      await repository.deleteTeam(1);

      expect(server.calls, [
        'DELETE /team/teams/1/members/1',
        'DELETE /team/teams/1',
      ]);
    });
  });

  group('권한', () {
    TeamRoleResponse role(Map<String, bool> permissions) =>
        TeamRoleResponse(id: 1, permissions: permissions);

    test('권한 키가 켜진 역할이 하나라도 있으면 허용한다', () {
      final roles = [
        role({'manage_team': false, 'manage_invites': true}),
        role({'manage_team': true}),
      ];

      expect(permissionsOf(roles), {
        TeamPermission.manageTeam,
        TeamPermission.manageInvites,
      });
    });

    test('administrator 는 모든 권한을 대신한다', () {
      final roles = [
        role({'administrator': true}),
      ];

      expect(permissionsOf(roles), TeamPermission.values.toSet());
    });

    test('역할이 없으면 아무것도 허용하지 않는다', () {
      expect(permissionsOf(const []), isEmpty);
    });

    test('소유자가 아니면 내 역할을 읽어 권한으로 바꾼다', () async {
      final server = FakeTeamServer()
        ..roles = [
          roleJson(),
          roleJson(id: 2, permissions: {'delete_team': true}),
        ];

      final permissions = await teamRepositoryOfTeamServer(
        server,
      ).fetchMyPermissions(const TeamResponse(id: 1, ownerId: 2), userId: 1);

      expect(server.calls, ['GET /team/teams/1/members/1/roles']);
      expect(permissions, {TeamPermission.deleteTeam});
    });

    test('소유자는 역할을 읽지 않고 모두 할 수 있다', () async {
      // dev 서버는 소유자의 역할 조회에 권한을 싣지 않는데도 소유자의 요청은 허용한다.
      final server = FakeTeamServer();

      final permissions = await teamRepositoryOfTeamServer(
        server,
      ).fetchMyPermissions(const TeamResponse(id: 1, ownerId: 1), userId: 1);

      expect(server.calls, isEmpty);
      expect(permissions, TeamPermission.values.toSet());
    });
  });

  group('Bloc', () {
    test('내 역할 권한을 읽어 할 수 있는 일을 정한다', () async {
      final server = FakeTeamServer()
        ..roles = [
          roleJson(),
          roleJson(id: 2, permissions: {'manage_team': true}),
        ];
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      final settings = _data(bloc).settings;
      expect(settings.name, '코워크');
      expect(settings.canManage, isTrue);
      expect(settings.canDelete, isFalse);
    });

    test('소유자는 역할과 관계없이 수정·삭제할 수 있다', () async {
      final server = FakeTeamServer()..team['ownerId'] = 1;
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      final settings = _data(bloc).settings;
      expect(settings.canManage, isTrue);
      expect(settings.canDelete, isTrue);
    });

    test('내 id 를 아직 모르면 읽어서 역할을 묻는다', () async {
      ProfileStore.instance.currentUserId = null;
      final server = FakeTeamServer();
      final bloc = _bloc(server)..add(const TeamSettingsEvent.requested());
      addTearDown(bloc.close);
      await bloc.stream.firstWhere((s) => s is AsyncSuccess<TeamSettingsData>);

      expect(server.calls, contains('GET /user/users/me'));
      expect(server.calls, contains('GET /team/teams/1/members/1/roles'));
    });

    test('역할을 못 읽으면 팀 정보는 읽기 전용으로 둔다', () async {
      final server = FakeTeamServer()
        ..failing.add('GET /team/teams/1/members/1/roles');
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      final settings = _data(bloc).settings;
      expect(settings.name, '코워크');
      expect(settings.permissionsFailed, isTrue);
      expect(settings.canManage, isFalse);
      expect(settings.canDelete, isFalse);
    });

    test('권한만 다시 읽어 할 수 있는 일을 정한다', () async {
      final server = FakeTeamServer()
        ..roles = [_admin]
        ..failing.add('GET /team/teams/1/members/1/roles');
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      server.failing.clear();

      bloc.add(const TeamSettingsEvent.permissionsRetried());
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<TeamSettingsData> &&
            !s.data.settings.permissionsFailed,
      );

      // 팀 상세는 다시 읽지 않는다.
      expect(server.calls, ['GET /team/teams/1/members/1/roles']);
      expect(_data(bloc).settings.canManage, isTrue);
      expect(_data(bloc).settings.canDelete, isTrue);
    });

    test('권한 다시 읽기가 또 실패하면 읽기 전용을 두고 사유를 알린다', () async {
      final server = FakeTeamServer()
        ..failing.add('GET /team/teams/1/members/1/roles');
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      bloc.add(const TeamSettingsEvent.permissionsRetried());
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<TeamSettingsData> && s.data.errorMessage != null,
      );

      expect(_data(bloc).errorMessage, '권한을 불러오지 못했어요.');
      expect(_data(bloc).settings.permissionsFailed, isTrue);
      expect(_data(bloc).settings.retryingPermissions, isFalse);
    });

    test('이름 바꾸기가 실패하면 이전 이름으로 되돌리고 사유를 알린다', () async {
      final server = FakeTeamServer()..roles = [_admin];
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      server
        ..failing.add('PATCH /team/teams/1')
        ..statusCode = 403;

      bloc.add(const TeamSettingsEvent.nameChanged('  새 이름  '));
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<TeamSettingsData> && s.data.errorMessage != null,
      );

      expect(server.bodies['PATCH /team/teams/1'], {'name': '새 이름'});
      expect(_data(bloc).settings.name, '코워크');
    });

    test('아이콘을 올리는 동안 표시하고, 끝나면 새 아이콘을 보인다', () async {
      final server = FakeTeamServer()..roles = [_admin];
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      final gate = Completer<void>();
      server.uploadGate = gate.future;

      bloc.add(TeamSettingsEvent.iconPicked(_iconFile('icon.png')));
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<TeamSettingsData> &&
            s.data.settings.uploadingIcon,
      );
      gate.complete();
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<TeamSettingsData> &&
            !s.data.settings.uploadingIcon,
      );

      expect(_data(bloc).settings.iconUrl, FakeTeamServer.uploadedIconUrl);
    });

    test('아이콘 업로드가 실패하면 기존 아이콘을 두고 사유를 알린다', () async {
      final server = FakeTeamServer()..roles = [_admin];
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      server.failing.add('POST /team/teams/icon/confirm');

      bloc.add(TeamSettingsEvent.iconPicked(_iconFile('icon.png')));
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<TeamSettingsData> && s.data.errorMessage != null,
      );

      final settings = _data(bloc).settings;
      expect(settings.iconUrl, 'https://cdn.test/team-icons/old.png');
      expect(settings.uploadingIcon, isFalse);
      expect(server.calls, isNot(contains('PATCH /team/teams/1/icon')));
    });

    test('아이콘 지우기가 실패하면 아이콘을 되돌린다', () async {
      final server = FakeTeamServer()..roles = [_admin];
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      server.failing.add('DELETE /team/teams/1/icon');

      bloc.add(const TeamSettingsEvent.iconRemoved());
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<TeamSettingsData> && s.data.errorMessage != null,
      );

      expect(
        _data(bloc).settings.iconUrl,
        'https://cdn.test/team-icons/old.png',
      );
    });
  });

  group('화면', () {
    /// 홈에서 팀 설정을 연 것처럼 띄운다. 설정 화면이 닫히며 돌려준 값을 [results] 에 담는다.
    Future<List<bool?>> pumpSettings(
      WidgetTester tester,
      FakeTeamServer server,
    ) async {
      final results = <bool?>[];
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: TextButton(
                onPressed: () async =>
                    results.add(await context.push<bool>('/settings')),
                child: const Text('열기'),
              ),
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const TeamSettingsView(teamId: 1),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<TeamRepository>.value(
              value: teamRepositoryOfTeamServer(server),
            ),
            RepositoryProvider<ProfileRepository>.value(
              value: profileRepositoryOfTeamServer(server),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.dark(),
            routerConfig: router,
          ),
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('권한이 없으면 팀 정보만 보이고 바꿀 항목은 숨긴다', (tester) async {
      await pumpSettings(tester, FakeTeamServer());

      expect(find.text('코워크'), findsOneWidget);
      expect(find.text('협업 서비스'), findsOneWidget);
      expect(find.text('팀 이름'), findsNothing);
      expect(find.text('팀 아이콘 변경'), findsNothing);
      expect(find.text('팀 삭제'), findsNothing);
      expect(find.text('팀 정보는 관리 권한이 있는 멤버만 바꿀 수 있어요.'), findsOneWidget);
    });

    testWidgets('권한을 못 읽으면 팀 정보를 두고 권한만 다시 불러온다', (tester) async {
      final server = FakeTeamServer()
        ..roles = [_admin]
        ..failing.add('GET /team/teams/1/members/1/roles');
      await pumpSettings(tester, server);

      expect(find.text('코워크'), findsOneWidget);
      expect(find.text('권한을 불러오지 못했어요'), findsOneWidget);
      expect(find.text('팀 이름'), findsNothing);
      expect(find.text('팀 정보는 관리 권한이 있는 멤버만 바꿀 수 있어요.'), findsNothing);

      server.failing.clear();
      await tester.tap(find.text('권한 다시 불러오기'));
      await tester.pumpAndSettle();

      expect(find.text('권한 다시 불러오기'), findsNothing);
      expect(find.text('팀 이름'), findsOneWidget);
      expect(find.text('팀 삭제'), findsOneWidget);
    });

    testWidgets('관리 권한만 있으면 팀 삭제는 숨긴다', (tester) async {
      final server = FakeTeamServer()
        ..roles = [
          roleJson(permissions: {'manage_team': true}),
        ];
      await pumpSettings(tester, server);

      expect(find.text('팀 이름'), findsOneWidget);
      expect(find.text('팀 아이콘 삭제'), findsOneWidget);
      expect(find.text('팀 삭제'), findsNothing);
    });

    testWidgets('팀 이름을 고치면 서버에 보내고 새 이름이 보인다', (tester) async {
      final server = FakeTeamServer()..roles = [_admin];
      await pumpSettings(tester, server);

      await tester.tap(find.text('팀 이름'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '새 이름');
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(server.bodies['PATCH /team/teams/1'], {'name': '새 이름'});
      expect(find.text('새 이름'), findsOneWidget);
    });

    testWidgets('아이콘을 고르면 올리고, 고르지 않으면 아무것도 보내지 않는다', (tester) async {
      final server = FakeTeamServer()..roles = [_admin];
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                TeamSettingsView(teamId: 1, pickIcon: () async => null),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<TeamRepository>.value(
              value: teamRepositoryOfTeamServer(server),
            ),
            RepositoryProvider<ProfileRepository>.value(
              value: profileRepositoryOfTeamServer(server),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      server.calls.clear();

      await tester.tap(find.text('팀 아이콘 변경'));
      await tester.pumpAndSettle();

      expect(server.calls, isEmpty);
    });

    testWidgets('팀을 삭제하면 서버에 보내고 true 로 닫힌다', (tester) async {
      final server = FakeTeamServer()..roles = [_admin];
      final results = await pumpSettings(tester, server);

      await tester.tap(find.text('팀 삭제'));
      await tester.pumpAndSettle();
      expect(find.text('팀을 삭제할까요?'), findsOneWidget);
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();

      expect(server.calls, contains('DELETE /team/teams/1'));
      expect(results, [true]);
      expect(find.text('열기'), findsOneWidget);
    });

    testWidgets('팀 삭제가 실패하면 다이얼로그에 사유를 두고 다시 누를 수 있다', (tester) async {
      final server = FakeTeamServer()
        ..roles = [_admin]
        ..failing.add('DELETE /team/teams/1');
      final results = await pumpSettings(tester, server);

      await tester.tap(find.text('팀 삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();

      expect(find.textContaining('팀을 삭제하지 못했어요.'), findsOneWidget);
      expect(results, isEmpty);

      server.failing.clear();
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();

      expect(results, [true]);
    });

    testWidgets('팀 삭제를 취소하면 아무것도 보내지 않는다', (tester) async {
      final server = FakeTeamServer()..roles = [_admin];
      await pumpSettings(tester, server);
      server.calls.clear();

      await tester.tap(find.text('팀 삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(server.calls, isEmpty);
      expect(find.text('팀 설정'), findsOneWidget);
    });
  });
}
