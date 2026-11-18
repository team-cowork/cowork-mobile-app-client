part of 'new_issue_bloc.dart';

sealed class NewIssueEvent extends Equatable {
  const NewIssueEvent();

  const factory NewIssueEvent.titleChanged(String title) = NewIssueTitleChanged;

  const factory NewIssueEvent.bodyChanged(String body) = NewIssueBodyChanged;

  /// 같은 라벨을 다시 누르면 고른 것을 푼다.
  const factory NewIssueEvent.labelToggled(String name) = NewIssueLabelToggled;

  /// 저장소의 라벨 목록을 읽는다.
  const factory NewIssueEvent.labelsRequested() = NewIssueLabelsRequested;

  @override
  List<Object?> get props => [];
}

final class NewIssueTitleChanged extends NewIssueEvent {
  const NewIssueTitleChanged(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

final class NewIssueBodyChanged extends NewIssueEvent {
  const NewIssueBodyChanged(this.body);

  final String body;

  @override
  List<Object?> get props => [body];
}

final class NewIssueLabelToggled extends NewIssueEvent {
  const NewIssueLabelToggled(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class NewIssueLabelsRequested extends NewIssueEvent {
  const NewIssueLabelsRequested();
}
