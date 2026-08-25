import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/enums/issue_priority.dart';
import '../../domain/enums/issue_status.dart';

part 'new_issue_event.dart';

class NewIssueForm extends Equatable {
  const NewIssueForm({
    this.title = '',
    this.status = IssueStatus.planned,
    this.labelIndex = 0,
    this.assigneeIndex,
    this.priority = IssuePriority.medium,
    this.dueDate = '',
    this.milestone = '',
  });

  final String title;
  final IssueStatus status;

  /// 라벨 후보(기능/버그/개선) 중 선택된 인덱스.
  final int labelIndex;

  /// 담당자 후보 중 선택된 인덱스. null이면 미지정.
  final int? assigneeIndex;

  final IssuePriority priority;

  /// 비어있으면 미지정.
  final String dueDate;

  /// 비어있으면 미지정.
  final String milestone;

  bool get canSubmit => title.trim().isNotEmpty;

  NewIssueForm copyWith({
    String? title,
    IssueStatus? status,
    int? labelIndex,
    int? assigneeIndex,
    bool clearAssignee = false,
    IssuePriority? priority,
    String? dueDate,
    String? milestone,
  }) => NewIssueForm(
    title: title ?? this.title,
    status: status ?? this.status,
    labelIndex: labelIndex ?? this.labelIndex,
    assigneeIndex: clearAssignee ? null : (assigneeIndex ?? this.assigneeIndex),
    priority: priority ?? this.priority,
    dueDate: dueDate ?? this.dueDate,
    milestone: milestone ?? this.milestone,
  );

  @override
  List<Object?> get props => [
    title,
    status,
    labelIndex,
    assigneeIndex,
    priority,
    dueDate,
    milestone,
  ];
}

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
