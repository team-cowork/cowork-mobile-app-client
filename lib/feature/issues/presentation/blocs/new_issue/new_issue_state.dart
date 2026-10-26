part of 'new_issue_bloc.dart';

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
