import 'package:equatable/equatable.dart';

import 'enums/issue_status.dart';
import 'issue_label.dart';

/// 프로젝트에 연결된 GitHub 저장소의 열린 이슈 하나.
class Issue extends Equatable {
  const Issue({
    required this.number,
    required this.title,
    required this.labels,
    required this.status,
    required this.author,
    required this.htmlUrl,
    required this.createdAt,
  });

  final int number;
  final String title;

  /// [IssueStatus.inProgress] 를 뜻하는 라벨은 빠진 나머지 라벨.
  final List<IssueLabel> labels;
  final IssueStatus status;

  /// 작성자 GitHub 사용자명.
  final String author;
  final String htmlUrl;

  /// 화면에 보일 만든 시각.
  final String createdAt;

  @override
  List<Object?> get props => [
    number,
    title,
    labels,
    status,
    author,
    htmlUrl,
    createdAt,
  ];
}
