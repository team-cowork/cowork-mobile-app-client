import 'package:cowork_app/feature/search/data/repositories/search_repository.dart';
import 'package:cowork_app/feature/search/domain/enums/avatar_color.dart';
import 'package:cowork_app/feature/search/domain/search_result.dart';
import 'package:cowork_app/feature/team/data/repositories/team_repository.dart';
import 'package:cowork_app/feature/team/presentation/blocs/invite_people/invite_people_bloc.dart';
import 'package:cowork_app/feature/team/presentation/views/team_invite_view.dart';
import 'package:cowork_app/feature/team/presentation/widgets/team_menu_sheet.dart';
import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../channel/chat_test_server.dart';
import '../search/fake_search_repository.dart';

SearchPersonResult _person(int id, String name, [String role = '']) =>
    SearchPersonResult(
      id: '$id',
      name: name,
      role: role,
      initial: name.characters.first,
      avatarColor: AvatarColor.blue,
    );

void main() {
  // 기본 800x600 뷰에서는 아래쪽 사람 찾기 칸이 화면 밖이라 폰 크기로 맞춘다.
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(400, 1400);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  /// 팀 1 에 7일 코드 `old`(먼저), 무제한 코드 `new`(나중), 무효화된 `gone` 이 있는 서버.
  FakeChatServer serverWithInvites() => FakeChatServer()
    ..invites[1] = [
      {
        'inviteCode': 'old',
        'duration': '7d',
        'expiresAt': '2026-11-17T00:00:00',
        'expired': false,
        'createdAt': '2026-11-10T00:00:00',
      },
      {
        'inviteCode': 'gone',
        'duration': '1d',
        'expiresAt': '2026-11-11T00:00:00',
        'expired': true,
        'createdAt': '2026-11-10T00:00:00',
      },
      {
        'inviteCode': 'new',
        'duration': 'never',
        'expiresAt': null,
        'expired': false,
        'createdAt': '2026-11-16T00:00:00',
      },
    ]
    ..members[1] = [1, 3];

  Future<FakeSearchRepository> pumpInvite(
    WidgetTester tester,
    FakeChatServer server,
  ) async {
    final search = FakeSearchRepository();
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<TeamRepository>.value(
            value: teamRepositoryOf(server),
          ),
          RepositoryProvider<SearchRepository>.value(value: search),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const TeamInviteView(teamId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return search;
  }

  final createCode = find.widgetWithText(CoworkButton, '코드 만들기');

  group('초대 코드', () {
    testWidgets('쓸 수 있는 코드만 최신순으로 보여 준다', (tester) async {
      await pumpInvite(tester, serverWithInvites());

      expect(find.text('gone'), findsNothing);
      final newTop = tester.getTopLeft(find.text('new')).dy;
      final oldTop = tester.getTopLeft(find.text('old')).dy;
      expect(newTop, lessThan(oldTop));
      expect(find.text('만료 없음'), findsOneWidget);
      // 서버 시각은 UTC 라 기기 시간으로 바꿔 보여 준다.
      final local = DateTime.utc(2026, 11, 17).toLocal();
      final hh = local.hour.toString().padLeft(2, '0');
      expect(
        find.text('${local.month}월 ${local.day}일 $hh:00까지'),
        findsOneWidget,
      );
    });

    testWidgets('기간을 골라 코드를 만들면 목록 맨 위에 붙는다', (tester) async {
      final server = serverWithInvites();
      await pumpInvite(tester, server);

      await tester.tap(find.text('30일'));
      await tester.pumpAndSettle();
      await tester.tap(createCode);
      await tester.pumpAndSettle();

      final created = server.invites[1]!.first;
      expect(created['duration'], '30d');
      final code = created['inviteCode'] as String;
      expect(
        tester.getTopLeft(find.text(code)).dy,
        lessThan(tester.getTopLeft(find.text('new')).dy),
      );
      // 목록을 다시 읽지 않는다.
      expect(
        server.requests.where((r) => r == 'GET /team/teams/1/invites'),
        hasLength(1),
      );
    });

    testWidgets('코드를 만들지 못하면 사유를 보여 주고 목록은 둔다', (tester) async {
      final server = serverWithInvites()
        ..failInvite = const ServerFailure(429, '요청이 너무 많습니다.');
      await pumpInvite(tester, server);

      await tester.tap(createCode);
      await tester.pumpAndSettle();

      expect(find.text('초대 코드를 만들지 못했어요'), findsOneWidget);
      expect(find.text('(429) 요청이 너무 많습니다.'), findsOneWidget);
      expect(find.text('new'), findsOneWidget);
    });

    testWidgets('목록을 읽을 권한이 없으면 화면 전체에 사유를 보여 준다', (tester) async {
      final server = serverWithInvites()
        ..failInvites = const ServerFailure(403, '권한이 없습니다.');
      await pumpInvite(tester, server);

      expect(find.text('멤버를 초대할 수 없어요'), findsOneWidget);
      expect(find.text('(403) 권한이 없습니다.'), findsOneWidget);
      expect(createCode, findsNothing);
    });

    testWidgets('복사하면 코드를 클립보드에 넣는다', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpInvite(tester, serverWithInvites());

      await tester.tap(find.bySemanticsLabel('초대 코드 복사').first);
      await tester.pumpAndSettle();

      expect(copied, 'new');
      expect(find.text('초대 코드를 복사했어요.'), findsOneWidget);
    });

    testWidgets('확인하면 무효화하고 목록에서 뺀다', (tester) async {
      final server = serverWithInvites();
      await pumpInvite(tester, server);

      await tester.tap(find.bySemanticsLabel('초대 코드 무효화').first);
      await tester.pumpAndSettle();
      expect(find.text('초대 코드를 무효화할까요?'), findsOneWidget);
      await tester.tap(find.widgetWithText(CoworkButton, '무효화'));
      await tester.pumpAndSettle();

      expect(server.requests, contains('DELETE /team/teams/1/invites/new'));
      expect(find.text('new'), findsNothing);
      expect(find.text('old'), findsOneWidget);
    });

    testWidgets('취소하면 무효화하지 않는다', (tester) async {
      final server = serverWithInvites();
      await pumpInvite(tester, server);

      await tester.tap(find.bySemanticsLabel('초대 코드 무효화').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(CoworkButton, '취소'));
      await tester.pumpAndSettle();

      expect(server.requests.where((r) => r.startsWith('DELETE')), isEmpty);
      expect(find.text('new'), findsOneWidget);
    });

    testWidgets('무효화가 실패하면 알리고 목록은 둔다', (tester) async {
      final server = serverWithInvites()
        ..failRevoke = const ServerFailure(403, '권한이 없습니다.');
      await pumpInvite(tester, server);

      await tester.tap(find.bySemanticsLabel('초대 코드 무효화').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(CoworkButton, '무효화'));
      await tester.pumpAndSettle();

      expect(find.text('(403) 권한이 없습니다.'), findsOneWidget);
      expect(find.text('new'), findsOneWidget);
    });
  });

  group('사람 찾아 초대', () {
    final inviteButton = find.byWidgetPredicate(
      (w) => w is CoworkButton && w.label.endsWith('초대'),
    );

    Future<void> search(WidgetTester tester, String query) async {
      await tester.enterText(find.byType(TextFormField), query);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
    }

    testWidgets('이미 멤버인 사람은 빼고, 고른 사람을 바로 초대한다', (tester) async {
      final server = serverWithInvites();
      final searchRepository = await pumpInvite(tester, server);

      // 아무도 고르지 않으면 초대할 수 없다.
      expect(tester.widget<CoworkButton>(inviteButton).enabled, isFalse);

      await search(tester, '도');
      searchRepository.people['도']!.complete([
        _person(3, '도현', '디자이너'),
        _person(5, '도윤', '백엔드 개발자'),
        _person(6, '도아'),
      ]);
      await tester.pumpAndSettle();

      // 3 은 이미 멤버다.
      expect(find.text('도현'), findsNothing);
      expect(find.text('백엔드 개발자'), findsOneWidget);

      await tester.tap(find.text('도윤'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('도아'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('도윤 빼기'), findsOneWidget);
      expect(find.widgetWithText(CoworkButton, '2명 초대'), findsOneWidget);

      // 고른 사람을 다시 누르면 빠진다.
      await tester.tap(find.bySemanticsLabel('도아 빼기'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(CoworkButton, '1명 초대'));
      await tester.pumpAndSettle();

      expect(server.invitedMembers.single, {
        'userIds': [5],
      });
      expect(find.text('1명을 팀에 초대했어요.'), findsOneWidget);
      // 초대한 사람은 이제 멤버라 결과에서 빠지고, 고른 목록도 비워진다.
      expect(find.bySemanticsLabel('도윤 빼기'), findsNothing);
      expect(find.text('도윤'), findsNothing);
      expect(find.text('도아'), findsOneWidget);
    });

    testWidgets('초대가 실패하면 사유를 보여 주고 고른 사람은 남긴다', (tester) async {
      final server = serverWithInvites()
        ..failInvite = const ServerFailure(403, '권한이 없습니다.');
      final searchRepository = await pumpInvite(tester, server);

      await search(tester, '도');
      searchRepository.people['도']!.complete([_person(5, '도윤')]);
      await tester.pumpAndSettle();
      await tester.tap(find.text('도윤'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(CoworkButton, '1명 초대'));
      await tester.pumpAndSettle();

      expect(find.text('초대하지 못했어요'), findsOneWidget);
      expect(find.text('(403) 권한이 없습니다.'), findsOneWidget);
      expect(find.bySemanticsLabel('도윤 빼기'), findsOneWidget);
    });

    testWidgets('찾을 사람이 없으면 안내한다', (tester) async {
      final searchRepository = await pumpInvite(tester, serverWithInvites());

      await search(tester, '없음');
      searchRepository.people['없음']!.complete(const []);
      await tester.pumpAndSettle();

      expect(find.text("'없음'(으)로 초대할 수 있는 사람이 없어요."), findsOneWidget);
    });
  });

  group('InvitePeopleBloc', () {
    test('늦게 온 이전 검색 응답은 버린다', () async {
      final search = FakeSearchRepository();
      final bloc = InvitePeopleBloc(
        teams: teamRepositoryOf(FakeChatServer()),
        search: search,
        teamId: 1,
      );
      addTearDown(bloc.close);

      bloc
        ..add(const InvitePeopleEvent.searched('도'))
        ..add(const InvitePeopleEvent.searched('도윤'));
      await Future<void>.delayed(Duration.zero);
      search.people['도윤']!.complete([_person(5, '도윤')]);
      await Future<void>.delayed(Duration.zero);
      search.people['도']!.complete([_person(6, '도아')]);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.query, '도윤');
      expect(bloc.state.results, AsyncState.success([_person(5, '도윤')]));
    });

    test('멤버 목록을 못 읽어도 검색과 초대는 된다', () async {
      final server = FakeChatServer()..failMembers = const ServerFailure(500);
      final bloc = InvitePeopleBloc(
        teams: teamRepositoryOf(server),
        search: FakeSearchRepository(),
        teamId: 1,
      )..add(const InvitePeopleEvent.started());
      addTearDown(bloc.close);

      bloc
        ..add(InvitePeopleEvent.toggled(_person(5, '도윤')))
        ..add(const InvitePeopleEvent.submitted());
      await bloc.stream.firstWhere((s) => s.submission is AsyncSuccess);

      expect(server.invitedMembers.single, {
        'userIds': [5],
      });
    });

    /// 서버가 id 를 안 주면 검색 매핑이 빈 문자열로 채운다.
    SearchPersonResult withoutId(String name) => SearchPersonResult(
      id: '',
      name: name,
      role: '',
      initial: name.characters.first,
      avatarColor: AvatarColor.blue,
    );

    test('id 를 못 읽은 사람은 빼고 보내고, 실제로 보낸 수만 센다', () async {
      final server = FakeChatServer();
      final bloc = InvitePeopleBloc(
        teams: teamRepositoryOf(server),
        search: FakeSearchRepository(),
        teamId: 1,
      );
      addTearDown(bloc.close);

      bloc
        ..add(InvitePeopleEvent.toggled(_person(5, '도윤')))
        ..add(InvitePeopleEvent.toggled(withoutId('이름만')))
        ..add(const InvitePeopleEvent.submitted());
      final done = await bloc.stream.firstWhere(
        (s) => s.submission is AsyncSuccess,
      );

      expect(server.invitedMembers.single, {
        'userIds': [5],
      });
      expect(done.submission, const AsyncState.success(1));
    });

    test('보낼 사람이 하나도 없으면 요청을 보내지 않고 실패로 알린다', () async {
      final server = FakeChatServer();
      final bloc = InvitePeopleBloc(
        teams: teamRepositoryOf(server),
        search: FakeSearchRepository(),
        teamId: 1,
      );
      addTearDown(bloc.close);

      bloc
        ..add(InvitePeopleEvent.toggled(withoutId('이름만')))
        ..add(const InvitePeopleEvent.submitted());
      final done = await bloc.stream.firstWhere(
        (s) => s.submission is AsyncFailure,
      );

      expect(server.invitedMembers, isEmpty);
      expect(server.requests.where((r) => r.startsWith('POST')), isEmpty);
      expect(
        done.submission,
        const AsyncState<int>.failure('고른 사람을 초대할 수 없어요.'),
      );
    });
  });

  testWidgets('팀 메뉴의 멤버 초대는 시트를 닫고 초대 화면 콜백을 부른다', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => TeamMenuSheet.show(
              context,
              teamName: '코워크',
              onInviteMembers: () => opened++,
            ),
            child: const Text('열기'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('멤버 초대'));
    await tester.pumpAndSettle();

    expect(opened, 1);
    expect(find.text('팀 설정'), findsNothing);
  });
}
