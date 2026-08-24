import 'package:equatable/equatable.dart';

import '../../profile/domain/profile_entity.dart';
import 'enums/issue_priority.dart';
import 'enums/issue_status.dart';
import 'issue_label.dart';

class Issue extends Equatable {
  const Issue({
    required this.id,
    required this.number,
    required this.title,
    required this.labels,
    required this.status,
    this.assignee,
    this.dueDate,
    this.priority,
    this.milestone,
    this.description = '',
  });

  final String id;
  final int number;
  final String title;
  final List<IssueLabel> labels;
  final IssueStatus status;
  final ProfileEntity? assignee;
  final String? dueDate;
  final IssuePriority? priority;
  final String? milestone;
  final String description;

  @override
  List<Object?> get props => [
    id,
    number,
    title,
    labels,
    status,
    assignee,
    dueDate,
    priority,
    milestone,
    description,
  ];
}
