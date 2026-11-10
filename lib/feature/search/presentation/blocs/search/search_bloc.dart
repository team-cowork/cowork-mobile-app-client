import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
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
    } catch (e, s) {
      Logger.e('검색 실패', tag: 'Search', error: e, stackTrace: s);
      emit(SearchState.failure(e is DioException ? dioErrorMessage(e) : null));
    }
  }
}
