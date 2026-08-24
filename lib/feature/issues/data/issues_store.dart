import '../../profile/domain/profile_entity.dart';
import '../domain/enums/issue_priority.dart';
import '../domain/enums/issue_status.dart';
import '../domain/enums/issue_tag_color.dart';
import '../domain/issue.dart';
import '../domain/issue_label.dart';

class IssuesStore {
  IssuesStore._();

  static final IssuesStore instance = IssuesStore._();

  String get projectLabel => '개발 · 백엔드';

  final List<Issue> _issues = [
    const Issue(
      id: 'issue-14',
      number: 14,
      title: '음성 채널 인원 제한 설정 UI',
      labels: [
        IssueLabel(name: '기능', color: IssueTagColor.blue),
        IssueLabel(name: '백엔드'),
      ],
      status: IssueStatus.planned,
      assignee: ProfileEntity(id: 103, name: '서연', avatarInitial: '서'),
      dueDate: '2026.03.20',
      priority: IssuePriority.high,
      milestone: 'MVP · 1차',
      description:
          '음성 채널 입장 시 최대 인원을 채널별로 설정할 수 있어야 함. 관리자가 채널 설정에서 2~50명 범위로 지정, '
          '초과 시 입장 차단 및 안내 토스트 노출. SmartThings 연동 로직과 충돌 없는지 확인 필요.',
    ),
    const Issue(
      id: 'issue-18',
      number: 18,
      title: '웹훅 보안 모드 시크릿 재발급 플로우',
      labels: [
        IssueLabel(name: '웹훅', color: IssueTagColor.amber),
        IssueLabel(name: '보안'),
      ],
      status: IssueStatus.planned,
      assignee: ProfileEntity(id: 102, name: '도윤', avatarInitial: '도'),
      priority: IssuePriority.medium,
      milestone: 'MVP · 1차',
      description: '웹훅 시크릿이 유출됐을 때 관리자가 재발급할 수 있는 플로우가 없음. 재발급 시 기존 시크릿은 즉시 만료 처리.',
    ),
    const Issue(
      id: 'issue-21',
      number: 21,
      title: '파일 채널 갤러리/리스트 뷰 토글',
      labels: [IssueLabel(name: '파일')],
      status: IssueStatus.planned,
      assignee: ProfileEntity(id: 101, name: 'junjuny', avatarInitial: '준'),
      priority: IssuePriority.low,
      description: '파일 채널에서 썸네일 갤러리와 파일명 리스트 뷰를 전환할 수 있는 토글 추가.',
    ),
    const Issue(
      id: 'issue-9',
      number: 9,
      title: 'PR #2 재연결 로직 리뷰 반영',
      labels: [IssueLabel(name: '버그', color: IssueTagColor.red)],
      status: IssueStatus.inProgress,
      assignee: ProfileEntity(id: 101, name: 'junjuny', avatarInitial: '준'),
      priority: IssuePriority.high,
      description: 'socket 인스턴스가 useEffect 의존성 배열에서 빠져있던 문제 수정 중.',
    ),
    const Issue(
      id: 'issue-11',
      number: 11,
      title: '클라우드 배포 파이프라인 캐시 최적화',
      labels: [IssueLabel(name: '배포', color: IssueTagColor.amber)],
      status: IssueStatus.inProgress,
      assignee: ProfileEntity(id: 102, name: '도윤', avatarInitial: '도'),
      priority: IssuePriority.medium,
      description: '빌드 캐시가 매 배포마다 무효화되는 문제로 배포 시간이 길어짐.',
    ),
    const Issue(
      id: 'issue-2',
      number: 2,
      title: '재연결 로직 리뷰',
      labels: [IssueLabel(name: '개선', color: IssueTagColor.green)],
      status: IssueStatus.done,
      assignee: ProfileEntity(id: 103, name: '서연', avatarInitial: '서'),
      priority: IssuePriority.low,
      description: 'CI 통과 확인 후 dev 서버에 반영 완료.',
    ),
    const Issue(
      id: 'issue-14-old',
      number: 5,
      title: '이슈 #14 클로즈',
      labels: [IssueLabel(name: '기능', color: IssueTagColor.blue)],
      status: IssueStatus.done,
      assignee: ProfileEntity(id: 101, name: 'junjuny', avatarInitial: '준'),
      priority: IssuePriority.low,
      description: '리뷰 반영 및 머지 완료.',
    ),
  ];

  List<Issue> get issues => List.unmodifiable(_issues);

  int get nextNumber =>
      (_issues.map((i) => i.number).fold(0, (a, b) => a > b ? a : b)) + 1;

  void add(Issue issue) => _issues.add(issue);
}
