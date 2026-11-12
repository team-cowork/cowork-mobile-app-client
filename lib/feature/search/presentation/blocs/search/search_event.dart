part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  const factory SearchEvent.started() = SearchStarted;
  const factory SearchEvent.requested(String query) = SearchRequested;
  const factory SearchEvent.moreMessagesRequested() =
      SearchMoreMessagesRequested;
  const factory SearchEvent.sectionRetried(SearchSection section) =
      SearchSectionRetried;

  @override
  List<Object?> get props => [];
}

/// 화면에 들어왔다. 기기에 저장한 최근 검색어를 불러온다.
final class SearchStarted extends SearchEvent {
  const SearchStarted();
}

/// [query] 로 채널·사람·메시지를 새로 검색한다. 비어 있으면 결과를 비운다.
final class SearchRequested extends SearchEvent {
  const SearchRequested(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// 메시지 검색 다음 페이지를 이어 붙인다. 받는 중이거나 끝이면 무시한다.
final class SearchMoreMessagesRequested extends SearchEvent {
  const SearchMoreMessagesRequested();
}

/// 실패한 [section] 만 지금 검색어로 다시 찾는다. 실패 상태가 아니면 무시한다.
final class SearchSectionRetried extends SearchEvent {
  const SearchSectionRetried(this.section);

  final SearchSection section;

  @override
  List<Object?> get props => [section];
}
