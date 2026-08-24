part of 'new_issue_bloc.dart';

sealed class NewIssueEvent extends Equatable {
  const NewIssueEvent();

  const factory NewIssueEvent.titleChanged(String title) =
      NewIssueTitleChanged;

  const factory NewIssueEvent.statusChanged(IssueStatus status) =
      NewIssueStatusChanged;

  const factory NewIssueEvent.labelChanged(int index) = NewIssueLabelChanged;

  const factory NewIssueEvent.assigneeToggled(int index) =
      NewIssueAssigneeToggled;

  @override
  List<Object?> get props => [];
}

final class NewIssueTitleChanged extends NewIssueEvent {
  const NewIssueTitleChanged(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

final class NewIssueStatusChanged extends NewIssueEvent {
  const NewIssueStatusChanged(this.status);

  final IssueStatus status;

  @override
  List<Object?> get props => [status];
}

final class NewIssueLabelChanged extends NewIssueEvent {
  const NewIssueLabelChanged(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class NewIssueAssigneeToggled extends NewIssueEvent {
  const NewIssueAssigneeToggled(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}
