import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../data/issues_store.dart';
import '../../domain/issue.dart';

part 'issues_event.dart';

typedef IssuesState = AsyncState<List<Issue>>;

class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {
  IssuesBloc() : super(const IssuesState.initial()) {
    on<IssuesRequested>(_onLoad);
    on<IssueAdded>(_onAdd);
  }

  void _onLoad(IssuesRequested event, Emitter<IssuesState> emit) {
    emit(const IssuesState.loading());
    try {
      emit(IssuesState.success(IssuesStore.instance.issues));
    } catch (_) {
      emit(const IssuesState.failure());
    }
  }

  void _onAdd(IssueAdded event, Emitter<IssuesState> emit) {
    IssuesStore.instance.add(event.issue);
    emit(IssuesState.success(IssuesStore.instance.issues));
  }
}
