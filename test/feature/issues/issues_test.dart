import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/issues/domain/issue_target.dart';
import 'package:cowork_app/feature/issues/presentation/blocs/issue_comments/issue_comments_cubit.dart';
import 'package:cowork_app/feature/issues/presentation/blocs/issues/issues_bloc.dart';
import 'package:cowork_app/feature/issues/presentation/widgets/issue_comment_composer.dart';
import 'package:cowork_app/feature/issues/presentation/views/issues_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'issue_test_server.dart';

const _target = IssueTarget(projectId: 1, repoId: 7, label: '개발 · backend');

IssuesData _data(IssuesBloc bloc) =>
    (bloc.state as AsyncSuccess<IssuesData>).data;

Future<IssuesBloc> _loaded(FakeIssueServer server) async {
  final bloc = IssuesBloc(
    issueRepositoryOf(server),
    refreshDelay: const Duration(milliseconds: 10),
  )..add(const IssuesEvent.requested());
  await bloc.stream.firstWhere((s) => s is! AsyncLoading<IssuesData>);
  return bloc;
}

void main() {
  group('이슈 목록 Bloc', () {
    test('대상 저장소와 열린 이슈를 읽는다', () async {
      final bloc = await _loaded(FakeIssueServer());
      addTearDown(bloc.close);

      expect(_data(bloc).target, _target);
      expect(_data(bloc).issues.map((i) => i.number), [14, 9]);
    });

    test('연결된 저장소가 없으면 대상 없이 빈 목록이다', () async {
      final bloc = await _loaded(FakeIssueServer()..repos = {});
      addTearDown(bloc.close);

      expect(_data(bloc).target, isNull);
      expect(_data(bloc).issues, isEmpty);
    });

    test('읽지 못하면 실패 상태가 된다', () async {
      final bloc = await _loaded(
        FakeIssueServer()..failing = 'GET /project/projects/me',
      );
      addTearDown(bloc.close);

      expect(bloc.state, isA<AsyncFailure<IssuesData>>());
    });

    test('이슈를 만들면 접수한 뒤 잠시 있다가 목록을 다시 읽는다', () async {
      final server = FakeIssueServer();
      // 서버가 GitHub 에 비동기로 만들어, 요청 직후가 아니라 나중에 목록에 들어간다.
      server.onCreateIssue = (body) =>
          Future<void>.delayed(const Duration(milliseconds: 5), () {
            server.issues = [
              ...server.issues,
              issueJson(30, body['title'] as String),
            ];
          });
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      bloc.add(
        const IssuesEvent.created(title: ' 새 이슈 ', body: '내용', label: '버그'),
      );
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<IssuesData> &&
            s.data.issues.any((i) => i.number == 30),
      );

      expect(server.bodies['POST /project/projects/1/github-repos/7/issues'], {
        'title': '새 이슈',
        'body': '내용',
        'label': '버그',
      });
    });

    test('만들지 못하면 사유를 싣고 목록은 그대로 둔다', () async {
      final server = FakeIssueServer()
        ..failing = 'POST /project/projects/1/github-repos/7/issues';
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      bloc.add(const IssuesEvent.created(title: '실패할 이슈'));
      await bloc.stream.firstWhere(
        (s) => s is AsyncSuccess<IssuesData> && s.data.errorMessage != null,
      );

      expect(_data(bloc).issues.map((i) => i.number), [14, 9]);
    });

    test('같은 사유로 연달아 실패해도 매번 알린다', () async {
      final server = FakeIssueServer()
        ..failing = 'POST /project/projects/1/github-repos/7/issues';
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      final errors = <String>[];
      final subscription = bloc.stream.listen((state) {
        if (state is AsyncSuccess<IssuesData> &&
            state.data.errorMessage != null) {
          errors.add(state.data.errorMessage!);
        }
      });
      addTearDown(subscription.cancel);

      bloc.add(const IssuesEvent.created(title: '첫 시도'));
      await pumpEventQueue();
      bloc.add(const IssuesEvent.created(title: '두 번째 시도'));
      await pumpEventQueue();

      expect(errors, hasLength(2));
      expect(errors.first, errors.last);
    });

    test('서버가 늦게 반영해도 만든 이슈가 보일 때까지 다시 읽는다', () async {
      final server = FakeIssueServer();
      // 새로고침 간격(10ms)보다 한참 늦게 목록에 들어간다.
      server.onCreateIssue = (body) =>
          Future<void>.delayed(const Duration(milliseconds: 35), () {
            server.issues = [
              ...server.issues,
              issueJson(30, body['title'] as String),
            ];
          });
      final bloc = await _loaded(server);
      addTearDown(bloc.close);

      bloc.add(const IssuesEvent.created(title: '늦게 반영되는 이슈'));
      await bloc.stream.firstWhere(
        (s) =>
            s is AsyncSuccess<IssuesData> &&
            s.data.issues.any((i) => i.number == 30),
      );

      final listCalls = server.calls
          .where((c) => c == 'GET /project/projects/1/github-repos/7/issues')
          .length;
      expect(listCalls, greaterThan(2));
    });

    test('만든 이슈가 끝내 안 보이면 정한 횟수만큼만 다시 읽고 그만둔다', () async {
      final server = FakeIssueServer();
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      server.calls.clear();

      bloc.add(const IssuesEvent.created(title: '반영되지 않는 이슈'));
      // 간격(10ms) × 횟수보다 넉넉히 기다린다.
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final listCalls = server.calls
          .where((c) => c == 'GET /project/projects/1/github-repos/7/issues')
          .length;
      expect(listCalls, IssuesBloc.maxRefreshAttempts);
    });

    test('기다리는 이슈가 없으면 새로고침은 한 번만 읽는다', () async {
      final server = FakeIssueServer();
      final bloc = await _loaded(server);
      addTearDown(bloc.close);
      server.calls.clear();

      bloc.add(const IssuesEvent.refreshed());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(server.calls, ['GET /project/projects/1/github-repos/7/issues']);
    });
  });

  group('댓글 Cubit', () {
    IssueCommentsCubit cubitOf(FakeIssueServer server) => IssueCommentsCubit(
      issueRepositoryOf(server),
      _target,
      14,
      refreshDelay: const Duration(milliseconds: 10),
    );

    test('댓글을 읽는다', () async {
      final cubit = cubitOf(FakeIssueServer());
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.comments.map((c) => c.message), ['확인했습니다.']);
      expect(cubit.state.comments.single.author, 'octocat');
    });

    test('댓글을 보내면 먼저 보이고, 서버 목록으로 맞춘다', () async {
      final server = FakeIssueServer();
      server.onCreateComment = (body) => server.comments = [
        ...server.comments,
        {
          'id': 2,
          'author': 'me',
          'body': body['body'],
          'htmlUrl': '',
          'createdAt': '2026-10-23T06:00:00Z',
        },
      ];
      final cubit = cubitOf(server);
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.send('  반영했어요  ');
      expect(cubit.state.comments.last.message, '반영했어요');
      expect(cubit.state.comments.last.timestamp, '방금');

      await cubit.stream.firstWhere((s) => s.comments.last.author == 'me');
      expect(cubit.state.comments, hasLength(2));
    });

    test('보내지 못하면 사유를 싣고 댓글을 넣지 않는다', () async {
      final server = FakeIssueServer()
        ..failing =
            'POST /project/projects/1/github-repos/7/issues/14/comments';
      final cubit = cubitOf(server);
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.send('실패할 댓글');

      expect(cubit.state.comments, hasLength(1));
      expect(cubit.state.error, isNotNull);
    });

    test('같은 사유로 연달아 보내지 못해도 매번 알린다', () async {
      final server = FakeIssueServer()
        ..failing =
            'POST /project/projects/1/github-repos/7/issues/14/comments';
      final cubit = cubitOf(server);
      addTearDown(cubit.close);
      await cubit.load();
      final errors = <String>[];
      final subscription = cubit.stream.listen((state) {
        if (state.error != null) errors.add(state.error!);
      });
      addTearDown(subscription.cancel);

      final first = await cubit.send('첫 시도');
      final second = await cubit.send('두 번째 시도');
      await pumpEventQueue();

      expect([first, second], [false, false]);
      expect(errors, hasLength(2));
    });

    test('서버가 접수하면 true 를 돌려준다', () async {
      final cubit = cubitOf(FakeIssueServer());
      addTearDown(cubit.close);
      await cubit.load();

      expect(await cubit.send('접수될 댓글'), isTrue);
    });

    test('서버 목록에 아직 없는 보낸 댓글은 남기고, 반영되면 서버 것으로 바꾼다', () async {
      final server = FakeIssueServer();
      // 첫 새로고침(10ms)보다 늦게 목록에 들어간다.
      server.onCreateComment = (body) =>
          Future<void>.delayed(const Duration(milliseconds: 35), () {
            server.comments = [
              ...server.comments,
              {
                'id': 2,
                'author': 'me',
                'body': body['body'],
                'htmlUrl': '',
                'createdAt': '2026-10-23T06:00:00Z',
              },
            ];
          });
      final cubit = cubitOf(server);
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.send('늦게 반영되는 댓글');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      // 서버 목록에 아직 없어도 보낸 댓글이 사라지지 않는다.
      expect(cubit.state.comments.last.message, '늦게 반영되는 댓글');
      expect(cubit.state.comments.last.timestamp, '방금');

      await cubit.stream.firstWhere((s) => s.comments.last.author == 'me');
      expect(cubit.state.comments, hasLength(2));
    });

    test('읽거나 보내는 사이 닫아도 오류가 나지 않는다', () async {
      final loading = cubitOf(FakeIssueServer());
      final load = loading.load();
      await loading.close();
      await load;

      final sending = cubitOf(FakeIssueServer());
      await sending.load();
      final send = sending.send('닫히는 중');
      await sending.close();
      await send;
    });
  });

  group('화면', () {
    Future<void> pumpIssues(WidgetTester tester, FakeIssueServer server) async {
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: issueRepositoryOf(server),
          child: MaterialApp.router(
            theme: AppTheme.dark(),
            routerConfig: GoRouter(
              routes: [
                GoRoute(path: '/', builder: (_, _) => const IssuesView()),
                GoRoute(
                  path: '/issues/detail',
                  builder: (_, _) => const Text('상세'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> pumpComposer(
      WidgetTester tester,
      IssueCommentsCubit cubit,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: const IssueCommentComposer(),
            ),
          ),
        ),
      );
    }

    IssueCommentsCubit commentsOf(FakeIssueServer server) => IssueCommentsCubit(
      issueRepositoryOf(server),
      _target,
      14,
      refreshDelay: const Duration(milliseconds: 10),
    );

    testWidgets('댓글을 못 보내면 쓴 내용을 입력창에 남긴다', (tester) async {
      final server = FakeIssueServer()
        ..failing =
            'POST /project/projects/1/github-repos/7/issues/14/comments';
      final cubit = commentsOf(server);
      addTearDown(cubit.close);
      await pumpComposer(tester, cubit);

      await tester.enterText(find.byType(TextField), '다시 보낼 댓글');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('다시 보낼 댓글'), findsOneWidget);
    });

    testWidgets('댓글이 접수되면 입력창을 비운다', (tester) async {
      final cubit = commentsOf(FakeIssueServer());
      addTearDown(cubit.close);
      await pumpComposer(tester, cubit);

      await tester.enterText(find.byType(TextField), '보낼 댓글');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('보낼 댓글'), findsNothing);
    });

    testWidgets('계획됨 이슈를 보여 주고 진행중 탭에서 진행중 이슈를 보여 준다', (tester) async {
      await pumpIssues(tester, FakeIssueServer());

      expect(find.text('개발 · backend'), findsOneWidget);
      expect(find.text('음성 채널 인원 제한'), findsOneWidget);
      expect(find.text('재연결 리뷰 반영'), findsNothing);

      await tester.tap(find.text('진행중 1'));
      await tester.pumpAndSettle();

      expect(find.text('재연결 리뷰 반영'), findsOneWidget);
    });

    testWidgets('연결된 저장소가 없으면 안내한다', (tester) async {
      await pumpIssues(tester, FakeIssueServer()..repos = {});

      expect(find.text('연결된 저장소가 없어요'), findsOneWidget);
    });

    testWidgets('새 이슈 시트에서 제목을 적고 라벨을 골라 만든다', (tester) async {
      final server = FakeIssueServer();
      await pumpIssues(tester, server);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '새 이슈 제목');
      await tester.tap(find.text('버그'));
      await tester.pump();
      await tester.tap(find.text('이슈 만들기'));
      await tester.pumpAndSettle();

      expect(server.bodies['POST /project/projects/1/github-repos/7/issues'], {
        'title': '새 이슈 제목',
        'label': '버그',
      });
      // 서버가 비동기로 만들므로 시간이 지난 뒤 목록을 다시 읽는다.
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
