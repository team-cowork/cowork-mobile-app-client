part of 'new_issue_bloc.dart';

class NewIssueForm extends Equatable {
  const NewIssueForm({
    this.title = '',
    this.body = '',
    this.labels = const [],
    this.label,
  });

  final String title;
  final String body;

  /// 저장소에 있는 라벨 이름.
  final List<String> labels;

  /// 고른 라벨. 없으면 라벨 없이 만든다.
  final String? label;

  bool get canSubmit => title.trim().isNotEmpty;

  NewIssueForm copyWith({
    String? title,
    String? body,
    List<String>? labels,
    String? label,
    bool clearLabel = false,
  }) => NewIssueForm(
    title: title ?? this.title,
    body: body ?? this.body,
    labels: labels ?? this.labels,
    label: clearLabel ? null : (label ?? this.label),
  );

  @override
  List<Object?> get props => [title, body, labels, label];
}
