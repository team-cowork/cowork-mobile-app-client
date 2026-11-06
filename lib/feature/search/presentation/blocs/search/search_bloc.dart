import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/repositories/recent_search_repository.dart';
import '../../../data/repositories/search_repository.dart';
import '../../../domain/search_result.dart';

part 'search_event.dart';
part 'search_state.dart';

/// [teamId] 팀 안에서 채널·사람·메시지를 검색한다.
///
/// 세 검색은 동시에 보내고 끝나는 대로 그 섹션만 채운다. 검색어를 빠르게 바꾸면 이전
/// 검색 응답이 나중에 올 수 있어, 검색마다 번호([_generation])를 매기고 지금 번호가
/// 아닌 응답은 버린다.
///
/// 최근 검색어는 [state] 가 원본이다. 기기 저장은 바뀔 때마다 기다리지 않고 덮어쓴다.
/// 저장이 실패해도 검색은 계속돼야 해서다.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repository, this._recent, {required this.teamId})
    : super(const SearchState()) {
    on<SearchStarted>(_onStarted);
    on<SearchRequested>(_onRequested);
    on<SearchMoreMessagesRequested>(_onMoreMessagesRequested);
  }

  final SearchRepository _repository;
  final RecentSearchRepository _recent;
  final int teamId;

  /// 마지막으로 시작한 검색의 번호. 응답이 올 때 이 값과 다르면 낡은 응답이다.
  int _generation = 0;

  /// 저장된 최근 검색어를 다 읽었는지. 읽기 전에 저장하면 기기의 기록을 지금 화면의
  /// 몇 개로 덮어써 버리므로, 그 전까지는 저장을 [_onStarted] 로 미룬다.
  bool _recentLoaded = false;

  /// 기기에 저장한 최근 검색어를 불러온다. 불러오는 사이 검색했으면 그 검색어를
  /// 앞에 두고 합쳐 다시 저장한다.
  Future<void> _onStarted(
    SearchStarted event,
    Emitter<SearchState> emit,
  ) async {
    var saved = const <String>[];
    try {
      saved = await _recent.load(teamId);
    } catch (e, s) {
      // 못 읽은 기록은 살릴 수 없다. 이번 화면의 검색어부터 다시 쌓는다.
      Logger.e('최근 검색어 불러오기 실패', tag: 'Search', error: e, stackTrace: s);
    }
    // 불러오는 사이 화면이 닫혔으면(로그아웃 포함) 저장하지 않는다. 로그아웃이 지운
    // 기록을 앞 사람의 검색어로 다시 채우게 된다.
    if (isClosed) return;
    _recentLoaded = true;
    final searched = state.recentSearches;
    final merged = [
      ...searched,
      ...saved.where((term) => !searched.contains(term)),
    ].take(RecentSearchRepository.maxTerms).toList();
    emit(state.copyWith(recentSearches: merged));
    if (searched.isNotEmpty) _persist(merged);
  }

  Future<void> _onRequested(
    SearchRequested event,
    Emitter<SearchState> emit,
  ) async {
    final generation = ++_generation;
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(SearchState(recentSearches: state.recentSearches));
      return;
    }

    final recentSearches = RecentSearchRepository.withTerm(
      state.recentSearches,
      query,
    );
    if (_recentLoaded) _persist(recentSearches);
    emit(
      SearchState(
        query: query,
        recentSearches: recentSearches,
        channels: const AsyncState.loading(),
        people: const AsyncState.loading(),
        messages: const AsyncState.loading(),
      ),
    );

    bool isCurrent() => generation == _generation;

    await Future.wait([
      _section(
        () => _repository.searchChannels(teamId: teamId, query: query),
        label: '채널 검색',
        isCurrent: isCurrent,
        apply: (result) => emit(state.copyWith(channels: result)),
      ),
      _section(
        () => _repository.searchPeople(teamId: teamId, query: query),
        label: '사람 검색',
        isCurrent: isCurrent,
        apply: (result) => emit(state.copyWith(people: result)),
      ),
      _section(
        () => _repository.searchMessages(teamId: teamId, query: query),
        label: '메시지 검색',
        isCurrent: isCurrent,
        apply: (result) => emit(state.copyWith(messages: result)),
      ),
    ]);
  }

  /// 검색 하나를 돌려 성공/실패를 [apply] 로 넘긴다. 그 사이 새 검색이 시작됐으면
  /// 결과를 버린다. 실패는 여기서 삼켜 다른 섹션 검색을 멈추지 않는다.
  Future<void> _section<T>(
    Future<T> Function() load, {
    required String label,
    required bool Function() isCurrent,
    required void Function(AsyncState<T> result) apply,
  }) async {
    final AsyncState<T> result;
    try {
      result = AsyncState.success(await load());
    } catch (e, s) {
      Logger.e('$label 실패', tag: 'Search', error: e, stackTrace: s);
      if (isCurrent()) apply(AsyncState.failure(_messageOf(e)));
      return;
    }
    if (isCurrent()) apply(result);
  }

  Future<void> _onMoreMessagesRequested(
    SearchMoreMessagesRequested event,
    Emitter<SearchState> emit,
  ) async {
    final messages = state.messages;
    if (state.loadingMoreMessages ||
        messages is! AsyncSuccess<SearchMessagePage> ||
        !messages.data.hasMore) {
      return;
    }

    final generation = _generation;
    final loaded = messages.data;
    emit(state.copyWith(loadingMoreMessages: true, moreMessagesFailed: false));
    try {
      final next = await _repository.searchMessages(
        teamId: teamId,
        query: state.query,
        before: loaded.nextCursor,
      );
      if (generation != _generation) return;
      emit(
        state.copyWith(
          messages: AsyncState.success(
            SearchMessagePage(
              messages: [...loaded.messages, ...next.messages],
              nextCursor: next.nextCursor,
            ),
          ),
          loadingMoreMessages: false,
        ),
      );
    } catch (e, s) {
      Logger.e('메시지 검색 다음 페이지 실패', tag: 'Search', error: e, stackTrace: s);
      if (generation != _generation) return;
      emit(
        state.copyWith(loadingMoreMessages: false, moreMessagesFailed: true),
      );
    }
  }

  /// 최근 검색어를 기기에 덮어쓴다. 기다리지 않고, 실패는 로그만 남긴다.
  void _persist(List<String> terms) {
    unawaited(
      _recent.save(teamId, terms).catchError((Object e, StackTrace s) {
        Logger.e('최근 검색어 저장 실패', tag: 'Search', error: e, stackTrace: s);
      }),
    );
  }

  static String _messageOf(Object error) =>
      error is DioException ? dioErrorMessage(error) : '잠시 후 다시 시도해 주세요.';
}
