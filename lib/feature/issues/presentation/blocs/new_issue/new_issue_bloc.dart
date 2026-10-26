import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/enums/issue_priority.dart';
import '../../../domain/enums/issue_status.dart';

part 'new_issue_event.dart';
part 'new_issue_state.dart';

/// 새 이슈 시트의 입력 상태를 관리하는 Bloc.
///
/// 목록([IssuesBloc])과 수명이 달라 별도 Bloc으로 둔다. 시트가 닫히면 함께 버려진다.
class NewIssueBloc extends Bloc<NewIssueEvent, NewIssueForm> {
  NewIssueBloc() : super(const NewIssueForm()) {
    on<NewIssueTitleChanged>(
      (event, emit) => emit(state.copyWith(title: event.title)),
    );
    on<NewIssueStatusChanged>(
      (event, emit) => emit(state.copyWith(status: event.status)),
    );
    on<NewIssueLabelChanged>(
      (event, emit) => emit(state.copyWith(labelIndex: event.index)),
    );
    on<NewIssueAssigneeToggled>((event, emit) {
      final cleared = state.assigneeIndex == event.index;
      emit(
        state.copyWith(
          assigneeIndex: cleared ? null : event.index,
          clearAssignee: cleared,
        ),
      );
    });
    on<NewIssuePriorityChanged>(
      (event, emit) => emit(state.copyWith(priority: event.priority)),
    );
    on<NewIssueDueDateChanged>(
      (event, emit) => emit(state.copyWith(dueDate: event.dueDate)),
    );
    on<NewIssueMilestoneChanged>(
      (event, emit) => emit(state.copyWith(milestone: event.milestone)),
    );
  }
}
