part of 'issues_bloc.dart';

sealed class IssuesEvent extends Equatable {
  const IssuesEvent();

  const factory IssuesEvent.requested() = IssuesRequested;

  const factory IssuesEvent.added(Issue issue) = IssueAdded;

  @override
  List<Object?> get props => [];
}

final class IssuesRequested extends IssuesEvent {
  const IssuesRequested();
}

final class IssueAdded extends IssuesEvent {
  const IssueAdded(this.issue);

  final Issue issue;

  @override
  List<Object?> get props => [issue];
}
