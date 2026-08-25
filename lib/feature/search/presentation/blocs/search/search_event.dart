part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  const factory SearchEvent.requested({String query}) = SearchRequested;

  @override
  List<Object?> get props => [];
}

final class SearchRequested extends SearchEvent {
  const SearchRequested({this.query = ''});

  final String query;

  @override
  List<Object?> get props => [query];
}
