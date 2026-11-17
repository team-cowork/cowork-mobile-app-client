import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/issues/domain/issue_target.dart';
import 'package:cowork_app/feature/issues/presentation/blocs/issue_comments/issue_comments_cubit.dart';
import 'package:cowork_app/feature/issues/presentation/blocs/issues/issues_bloc.dart';
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
