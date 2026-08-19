import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../data/search_store.dart';
import '../../domain/search_result.dart';

part 'search_event.dart';

/// 검색 화면 상태. 성공 시 [SearchOverview]를 담는다.
typedef SearchState = AsyncState<SearchOverview>;

/// 검색 화면 상태를 관리하는 Bloc.
///
/// 현재는 목(mock) 데이터를 반환한다. 실제 API 연동 시 [_onLoad] 내부만 교체하면 된다.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState.initial()) {
    on<SearchRequested>(_onLoad);
  }

  void _onLoad(SearchRequested event, Emitter<SearchState> emit) {
    emit(const SearchState.loading());
    try {
      emit(SearchState.success(SearchStore.instance.overview));
    } catch (_) {
      emit(const SearchState.failure());
    }
  }
}
