part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  /// 검색 화면 데이터 로드를 요청한다.
  const factory SearchEvent.requested() = SearchRequested;

  @override
  List<Object?> get props => [];
}

final class SearchRequested extends SearchEvent {
  const SearchRequested();
}
