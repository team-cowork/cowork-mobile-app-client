import 'package:cowork_app/feature/issues/data/model/issue_mapping.dart';
import 'package:cowork_app/feature/issues/data/model/requests/create_issue_request.dart';
import 'package:cowork_app/feature/issues/domain/enums/issue_status.dart';
import 'package:cowork_app/feature/issues/domain/issue_target.dart';
import 'package:flutter_test/flutter_test.dart';

import 'issue_test_server.dart';

const _target = IssueTarget(projectId: 1, repoId: 7, label: '개발 · backend');

void main() {
  group('대상 저장소', () {
    test('참여한 프로젝트의 첫 연결 저장소를 고른다', () async {
      final server = FakeIssueServer();

      final target = await issueRepositoryOf(server).fetchTarget();

      expect(target, _target);
    });

    test('저장소가 연결되지 않은 프로젝트는 건너뛴다', () async {
      final server = FakeIssueServer()
        ..projects = [
          {'id': 2, 'name': '비어 있는 프로젝트'},
          {'id': 1, 'name': '개발'},
        ];

      final target = await issueRepositoryOf(server).fetchTarget();

      expect(target?.label, '개발 · backend');
      expect(server.calls, contains('GET /project/projects/2/github-repos'));
    });

    test('연결된 저장소가 하나도 없으면 null 이다', () async {
      final server = FakeIssueServer()..repos = {};

      expect(await issueRepositoryOf(server).fetchTarget(), isNull);
    });
  });

  test('이슈 목록과 라벨, 댓글을 저장소 경로로 읽는다', () async {
    final server = FakeIssueServer();
    final repository = issueRepositoryOf(server);

    final issues = await repository.fetchIssues(_target);
    final labels = await repository.fetchLabels(_target);
    final comments = await repository.fetchComments(_target, 14);

    expect(issues.map((i) => i.number), [14, 9]);
    expect(labels.map((l) => l.name), ['기능', '진행중', '버그']);
    expect(comments.single.author, 'octocat');
    expect(server.calls, [
      'GET /project/projects/1/github-repos/7/issues',
      'GET /project/projects/1/github-repos/7/issues/labels',
      'GET /project/projects/1/github-repos/7/issues/14/comments',
    ]);
  });

  test('이슈를 만들 때 비어 있는 본문과 라벨은 보내지 않는다', () async {
    final server = FakeIssueServer();
    final repository = issueRepositoryOf(server);

    await repository.createIssue(
      _target,
      const CreateIssueRequest(title: '제목만'),
    );
    await repository.createIssue(
      _target,
      const CreateIssueRequest(title: '다 있음', body: '내용', label: '버그'),
    );

    expect(server.bodies['POST /project/projects/1/github-repos/7/issues'], {
      'title': '다 있음',
      'body': '내용',
      'label': '버그',
    });
    expect(server.calls.where((c) => c.startsWith('POST')), hasLength(2));
  });

  test('댓글은 본문만 보낸다', () async {
    final server = FakeIssueServer();

    await issueRepositoryOf(server).createComment(_target, 14, '확인했어요');

    expect(
      server
          .bodies['POST /project/projects/1/github-repos/7/issues/14/comments'],
      {'body': '확인했어요'},
    );
  });

  group('매핑', () {
    test('진행중 라벨이 붙은 이슈는 진행중이고 그 라벨은 숨긴다', () async {
      final server = FakeIssueServer();
      final issues = [
        for (final issue in await issueRepositoryOf(
          server,
        ).fetchIssues(_target))
          issueOf(issue),
      ];

      final planned = issues.firstWhere((i) => i.number == 14);
      final inProgress = issues.firstWhere((i) => i.number == 9);
      expect(planned.status, IssueStatus.planned);
      expect(inProgress.status, IssueStatus.inProgress);
      expect(inProgress.labels.map((l) => l.name), ['버그']);
      expect(inProgress.author, 'octocat');
    });

    test('저장소 주소에서 이름만 꺼낸다', () {
      expect(repoNameOf('https://github.com/org/backend'), 'backend');
      expect(repoNameOf('https://github.com/org/backend/'), 'backend');
      expect(repoNameOf('https://github.com/org/backend.git'), 'backend');
    });
  });
}
