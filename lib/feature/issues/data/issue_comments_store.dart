import '../../profile/domain/profile_entity.dart';
import '../domain/issue_comment.dart';

class IssueCommentsStore {
  IssueCommentsStore._();

  static final IssueCommentsStore instance = IssueCommentsStore._();

  final Map<int, List<IssueComment>> _commentsByIssue = {
    9: [
      const IssueComment(
        id: 'comment-9-1',
        author: ProfileEntity(id: 102, name: '도윤', avatarInitial: '도'),
        message: 'useEffect 의존성 배열에 socket 인스턴스 추가하면 될 것 같아요.',
        timestamp: '오늘 14:22',
      ),
      const IssueComment(
        id: 'comment-9-2',
        author: ProfileEntity(id: 101, name: 'junjuny', avatarInitial: '준'),
        message: '반영했습니다. 리뷰 부탁드려요.',
        timestamp: '오늘 14:30',
      ),
    ],
  };

  List<IssueComment> commentsFor(int issueNumber) =>
      List.unmodifiable(_commentsByIssue[issueNumber] ?? const []);

  void addComment(int issueNumber, IssueComment comment) {
    _commentsByIssue.putIfAbsent(issueNumber, () => []).add(comment);
  }
}
