import 'dart:async';

import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/feature/search/data/repositories/recent_search_repository.dart';
import 'package:cowork_app/feature/search/domain/search_result.dart';
import 'package:cowork_app/feature/search/presentation/blocs/search/search_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_search_repository.dart';

/// 비동기 응답이 Bloc 에 반영되도록 이벤트 루프를 한 바퀴 돌린다.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeSearchRepository repository;
  late FakeRecentSearchRepository recent;
  late SearchBloc bloc;

  setUp(() {
    repository = FakeSearchRepository();
    recent = FakeRecentSearchRepository();
    bloc = SearchBloc(repository, recent, teamId: 3);
  });

  tearDown(() => bloc.close());

  test('늦게 도착한 이전 검색 응답은 버리고 마지막 검색 결과만 남긴다', () async {
    bloc.add(const SearchRequested('재연'));
    await _settle();
    bloc.add(const SearchRequested('재연결'));
    await _settle();

    repository.completeAll('재연결');
    await _settle();
    repository.completeAll('재연');
    await _settle();

    expect(bloc.state.query, '재연결');
    expect(
      bloc.state.channels,
      AsyncState<List<SearchChannelResult>>.success([channelNamed('재연결')]),
    );
  });

  test('한 섹션이 실패해도 다른 섹션은 결과를 보여준다', () async {
    bloc.add(const SearchRequested('도윤'));
    await _settle();

    repository.channels['도윤']!.complete(const []);
    repository.people['도윤']!.completeError(
      DioException(
        requestOptions: RequestOptions(),
        response: Response(requestOptions: RequestOptions(), statusCode: 503),
      ),
    );
    repository.messages['도윤|null']!.complete(
      const SearchMessagePage(messages: [], nextCursor: null),
    );
    await _settle();

    expect(bloc.state.people, isA<AsyncFailure<List<SearchPersonResult>>>());
    expect((bloc.state.people as AsyncFailure).message, contains('503'));
    expect(bloc.state.channels, isA<AsyncSuccess<List<SearchChannelResult>>>());
    expect(bloc.state.messages, isA<AsyncSuccess<SearchMessagePage>>());
  });

  test('다음 페이지는 커서로 받아 이어 붙이고, 받는 중 요청은 한 번만 보낸다', () async {
    bloc.add(const SearchRequested('배포'));
    await _settle();
    repository.completeAll('배포', nextCursor: 'c1');
    await _settle();

    bloc
      ..add(const SearchMoreMessagesRequested())
      ..add(const SearchMoreMessagesRequested());
    await _settle();
    expect(bloc.state.loadingMoreMessages, isTrue);
    expect(repository.messages.keys, ['배포|null', '배포|c1']);

    repository.messages['배포|c1']!.complete(
      SearchMessagePage(messages: [messageWithId('배포-2')], nextCursor: null),
    );
    await _settle();

    final page = (bloc.state.messages as AsyncSuccess<SearchMessagePage>).data;
    expect([for (final m in page.messages) m.id], ['배포-1', '배포-2']);
    expect(page.hasMore, isFalse);
    expect(bloc.state.loadingMoreMessages, isFalse);

    bloc.add(const SearchMoreMessagesRequested());
    await _settle();
    expect(repository.messages.length, 2, reason: '마지막 페이지면 더 요청하지 않는다');
  });

  test('다음 페이지 실패는 기존 메시지를 지우지 않고 실패만 표시한다', () async {
    bloc.add(const SearchRequested('배포'));
    await _settle();
    repository.completeAll('배포', nextCursor: 'c1');
    await _settle();

    bloc.add(const SearchMoreMessagesRequested());
    await _settle();
    repository.messages['배포|c1']!.completeError(Exception('offline'));
    await _settle();

    expect(bloc.state.moreMessagesFailed, isTrue);
    expect(bloc.state.loadingMoreMessages, isFalse);
    final page = (bloc.state.messages as AsyncSuccess<SearchMessagePage>).data;
    expect(page.messages, hasLength(1));
  });

  test('검색어를 비우면 결과를 비우고 최근 검색어는 최신순으로 남긴다', () async {
    bloc
      ..add(const SearchStarted())
      ..add(const SearchRequested(' 배포 '))
      ..add(const SearchRequested('회고'))
      ..add(const SearchRequested('배포'))
      ..add(const SearchRequested(''));
    await _settle();

    expect(bloc.state.query, '');
    expect(bloc.state.channels, isA<AsyncInitial<List<SearchChannelResult>>>());
    expect(bloc.state.recentSearches, ['배포', '회고']);
    expect(recent.saved[3], ['배포', '회고'], reason: '기기에도 같은 순서로 저장한다');
  });

  test('들어오면 저장된 그 팀의 최근 검색어를 불러온다', () async {
    recent.saved
      ..[3] = ['회고', '배포']
      ..[4] = ['다른 팀'];

    bloc.add(const SearchStarted());
    await _settle();

    expect(bloc.state.recentSearches, ['회고', '배포']);
  });

  test('불러오는 사이 검색하면 그 검색어를 앞에 두고 합쳐 저장한다', () async {
    recent.saved[3] = ['회고', '배포'];
    final gate = Completer<void>();
    recent.loadGate = gate.future;

    bloc
      ..add(const SearchStarted())
      ..add(const SearchRequested('배포'));
    await _settle();
    gate.complete();
    await _settle();

    expect(bloc.state.recentSearches, ['배포', '회고']);
    expect(recent.saved[3], ['배포', '회고']);
  });

  test('불러오는 사이 화면이 닫히고 기록이 지워지면 다시 저장하지 않는다', () async {
    recent.saved[3] = ['회고'];
    final gate = Completer<void>();
    recent.loadGate = gate.future;

    bloc
      ..add(const SearchStarted())
      ..add(const SearchRequested('배포'));
    await _settle();
    // 세션이 만료돼 검색 화면이 닫히고, 로그아웃 처리로 기록이 지워진다.
    unawaited(bloc.close());
    await recent.clearAll();
    gate.complete();
    await _settle();

    expect(recent.saved, isEmpty);
  });

  test('최근 검색어는 중복 없이 최대 개수까지만 남긴다', () {
    var terms = <String>[];
    for (var i = 0; i < RecentSearchRepository.maxTerms + 2; i++) {
      terms = RecentSearchRepository.withTerm(terms, '$i');
    }
    terms = RecentSearchRepository.withTerm(terms, '5');

    expect(terms, hasLength(RecentSearchRepository.maxTerms));
    expect(terms.first, '5');
    expect(terms.where((t) => t == '5'), hasLength(1));
    expect(terms, isNot(contains('0')), reason: '가장 오래된 것부터 버린다');
  });
}
