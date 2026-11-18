import 'issue.dart';
import 'issue_target.dart';

/// 이슈 상세 화면으로 넘기는 값. 댓글을 읽고 쓰려면 이슈가 속한 저장소가 필요하다.
class IssueDetailArgs {
  const IssueDetailArgs({required this.issue, required this.target});

  final Issue issue;
  final IssueTarget target;
}
