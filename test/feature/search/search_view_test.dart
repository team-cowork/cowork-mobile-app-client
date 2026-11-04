import 'package:cowork_app/feature/search/data/repositories/recent_search_repository.dart';
import 'package:cowork_app/feature/search/data/repositories/search_repository.dart';
import 'package:cowork_app/feature/search/domain/search_result.dart';
import 'package:cowork_app/feature/search/presentation/views/search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'fake_search_repository.dart';

Widget _app(FakeSearchRepository repository) => MultiRepositoryProvider(
  providers: [
    RepositoryProvider<SearchRepository>.value(value: repository),
    RepositoryProvider<RecentSearchRepository>.value(
      value: FakeRecentSearchRepository(),
    ),
  ],
  child: const MaterialApp(home: SearchView(teamId: 3)),
);

/// 결과를 누르면 갈 채널 화면을 경로 글자로 대신하는 앱.
Widget _routedApp(FakeSearchRepository repository) => MultiRepositoryProvider(
  providers: [
    RepositoryProvider<SearchRepository>.value(value: repository),
    RepositoryProvider<RecentSearchRepository>.value(
      value: FakeRecentSearchRepository(),
    ),
  ],
  child: MaterialApp.router(
    routerConfig: GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchView(teamId: 3),
        ),
        GoRoute(
          path: '/chat/channel/:channelId',
          builder: (context, state) =>
              Text('채널 ${state.pathParameters['channelId']}'),
        ),
      ],
    ),
  ),
);

/// [query] 로 검색하고 채널 `6`, 채널 `7` 의 메시지 하나를 결과로 받는다.
Future<void> _searchWithResults(
  WidgetTester tester,
  FakeSearchRepository repository,
  String query,
) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
  repository.channels[query]!.complete([
    const SearchChannelResult(id: '6', name: '백엔드방', description: ''),
  ]);
  repository.people[query]!.complete(const []);
  repository.messages['$query|null']!.complete(
    SearchMessagePage(
      messages: [
        SearchMessageResult(
          id: 'm1',
          channelId: 7,
          authorId: 1,
          content: '배포 메시지',
          highlights: const [],
          createdAt: DateTime.utc(2026, 11, 1),
        ),
      ],
      nextCursor: null,
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('채널 결과를 누르면 그 채널 화면으로 간다', (tester) async {
    final repository = FakeSearchRepository();
    await tester.pumpWidget(_routedApp(repository));
    await _searchWithResults(tester, repository, '백엔드');

    await tester.tap(find.text('백엔드방'));
    await tester.pumpAndSettle();

    expect(find.text('채널 6'), findsOneWidget);
  });

  testWidgets('메시지 결과를 누르면 메시지가 있는 채널로 간다', (tester) async {
    final repository = FakeSearchRepository();
    await tester.pumpWidget(_routedApp(repository));
    await _searchWithResults(tester, repository, '배포');

    await tester.tap(find.text('배포 메시지'));
    await tester.pumpAndSettle();

    expect(find.text('채널 7'), findsOneWidget);
  });

  testWidgets('검색 중 로딩이 보여도 검색창 입력은 지워지지 않는다', (tester) async {
    final repository = FakeSearchRepository();
    await tester.pumpWidget(_app(repository));

    await tester.enterText(find.byType(TextField), '배포');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('채널'), findsOneWidget, reason: '섹션이 로딩으로 보인다');
    expect(find.widgetWithText(TextField, '배포'), findsOneWidget);

    repository.completeAll('배포');
    await tester.pump();

    expect(find.widgetWithText(TextField, '배포'), findsOneWidget);
    expect(find.text('배포'), findsWidgets);
  });

  testWidgets('실패한 섹션만 재시도 카드로 바뀐다', (tester) async {
    final repository = FakeSearchRepository();
    await tester.pumpWidget(_app(repository));

    await tester.enterText(find.byType(TextField), '도윤');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    repository.channels['도윤']!.complete([channelNamed('도윤방')]);
    repository.people['도윤']!.completeError(Exception('down'));
    repository.messages['도윤|null']!.complete(
      const SearchMessagePage(messages: [], nextCursor: null),
    );
    await tester.pump();

    expect(find.text('도윤방'), findsOneWidget);
    expect(find.text('사람 검색에 실패했어요'), findsOneWidget);
    expect(find.text('메시지'), findsNothing, reason: '빈 섹션은 숨긴다');
  });

  test('<em> 으로 감싼 구간만 강조 스타일이 된다', () {
    const base = TextStyle(fontWeight: FontWeight.w400);
    const em = TextStyle(fontWeight: FontWeight.w700);

    final spans = highlightSpansOf(
      'PR <em>재연결</em> 로직 <em>리뷰</em>',
      base: base,
      highlight: em,
    );

    expect(
      [for (final s in spans) (s.text, s.style)],
      [('PR ', base), ('재연결', em), (' 로직 ', base), ('리뷰', em)],
    );
  });
}
