import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../data/search_store.dart';
import '../../../domain/search_result.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState.initial()) {
    on<SearchRequested>(_onLoad);
  }

  void _onLoad(SearchRequested event, Emitter<SearchState> emit) {
    emit(const SearchState.loading());
    try {
      emit(SearchState.success(SearchStore.instance.search(event.query)));
    } catch (_) {
      emit(const SearchState.failure());
    }
  }
}
