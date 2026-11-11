import 'dart:async';

import 'package:cowork_app/feature/search/data/repositories/recent_search_repository.dart';
import 'package:cowork_app/feature/search/data/repositories/search_repository.dart';
import 'package:cowork_app/feature/search/domain/search_result.dart';

/// 검색어별로 응답을 붙잡아 두는 가짜 저장소. 테스트가 [Completer] 로 응답 순서와
/// 성공/실패를 정한다.
class FakeSearchRepository implements SearchRepository {
  final channels = <String, Completer<List<SearchChannelResult>>>{};
  final people = <String, Completer<List<SearchPersonResult>>>{};

  /// `검색어|커서` → 응답.
  final messages = <String, Completer<SearchMessagePage>>{};

  @override
  Future<List<SearchChannelResult>> searchChannels({
    required int teamId,
    required String query,
  }) => channels.putIfAbsent(query, Completer.new).future;

  @override
  Future<List<SearchPersonResult>> searchPeople({
    required int teamId,
    required String query,
  }) => people.putIfAbsent(query, Completer.new).future;

  @override
  Future<SearchMessagePage> searchMessages({
    required int teamId,
    required String query,
    String? before,
  }) => messages.putIfAbsent('$query|$before', Completer.new).future;

  /// [query] 의 첫 검색을 셋 다 [channel] 하나만 있는 결과로 끝낸다.
  void completeAll(String query, {String? nextCursor}) {
    channels[query]!.complete([channelNamed(query)]);
    people[query]!.complete(const []);
    messages['$query|null']!.complete(
      SearchMessagePage(
        messages: [messageWithId('$query-1')],
        nextCursor: nextCursor,
      ),
    );
  }
}

SearchChannelResult channelNamed(String name) =>
    SearchChannelResult(id: name, name: name, description: '');

SearchMessageResult messageWithId(String id) => SearchMessageResult(
  id: id,
  channelId: 1,
  authorId: 1,
  content: id,
  highlights: const [],
  createdAt: DateTime.utc(2026, 11, 1),
);

/// 기기 저장 대신 메모리 맵에 두는 최근 검색어 저장소.
class FakeRecentSearchRepository implements RecentSearchRepository {
  FakeRecentSearchRepository([Map<int, List<String>>? saved])
    : saved = saved ?? {};

  /// 팀 id → 저장된 검색어.
  final Map<int, List<String>> saved;

  /// 걸어 두면 [load] 가 이 Future 가 끝날 때까지 기다린다.
  Future<void>? loadGate;

  @override
  Future<List<String>> load(int teamId) async {
    await loadGate;
    return saved[teamId] ?? const [];
  }

  @override
  Future<void> save(int teamId, List<String> terms) async =>
      saved[teamId] = terms;

  @override
  Future<void> clearAll() async => saved.clear();
}
