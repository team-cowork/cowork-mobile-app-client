import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/issues_store.dart';
import '../../../domain/issue.dart';

part 'issues_event.dart';
part 'issues_state.dart';

class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {
  IssuesBloc() : super(const IssuesState.initial()) {
    on<IssuesRequested>(_onLoad);
    on<IssueAdded>(_onAdd);
  }

  void _onLoad(IssuesRequested event, Emitter<IssuesState> emit) {
    emit(const IssuesState.loading());
    try {
      emit(IssuesState.success(IssuesStore.instance.issues));
    } catch (e, s) {
      Logger.e('이슈 조회 실패', tag: 'Issues', error: e, stackTrace: s);
      emit(IssuesState.failure(failureMessageOf(e)));
    }
  }

  void _onAdd(IssueAdded event, Emitter<IssuesState> emit) {
    IssuesStore.instance.add(event.issue);
    emit(IssuesState.success(IssuesStore.instance.issues));
  }
}
