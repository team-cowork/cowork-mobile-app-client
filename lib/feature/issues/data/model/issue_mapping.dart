import '../../../chat/data/model/chat_message_mapping.dart';
import '../../domain/enums/issue_status.dart';
import '../../domain/issue.dart';
import '../../domain/issue_comment.dart';
import '../../domain/issue_label.dart';
import 'responses/github_comment_response.dart';
import 'responses/github_issue_response.dart';

/// 서버에 상태가 따로 없어, 이 라벨이 붙은 이슈를 진행중으로 본다. 웹 이슈 보드와 같다.
const inProgressLabel = '진행중';

/// 서버 이슈를 화면 이슈로. 시각은 기기 시간대로 [now] 기준 상대 표기한다.
Issue issueOf(GithubIssueResponse issue, {DateTime? now}) => Issue(
  number: issue.number,
  title: issue.title,
  labels: [
    for (final name in issue.labels)
      if (name != inProgressLabel) IssueLabel(name: name),
  ],
  status: issue.labels.contains(inProgressLabel)
      ? IssueStatus.inProgress
      : IssueStatus.planned,
  author: issue.author,
  htmlUrl: issue.htmlUrl,
  createdAt: chatTimestampOf(issue.createdAt, now: now),
);

IssueComment issueCommentOf(GithubCommentResponse comment, {DateTime? now}) =>
    IssueComment(
      id: '${comment.id}',
      author: comment.author,
      message: comment.body,
      timestamp: chatTimestampOf(comment.createdAt, now: now),
    );

/// `https://github.com/org/repo` 의 `repo`. 슬래시와 `.git` 은 뗀다.
String repoNameOf(String githubRepoUrl) {
  final trimmed = githubRepoUrl.replaceFirst(RegExp(r'/+$'), '');
  final name = trimmed.substring(trimmed.lastIndexOf('/') + 1);
  return name.endsWith('.git') ? name.substring(0, name.length - 4) : name;
}
