import 'package:cowork_app/feature/project/data/model/requests/create_project_request.dart';
import 'package:flutter_test/flutter_test.dart';

import '../channel/chat_test_server.dart';

void main() {
  test('팀 프로젝트 목록은 페이지 응답의 content 를 서버 순서대로 준다', () async {
    final server = FakeChatServer()
      ..projects[1] = [
        {'id': 6, 'name': '서버', 'status': 'ACTIVE', 'position': 0},
        {'id': 5, 'name': '앱', 'status': 'ARCHIVED', 'position': 1},
      ];

    final projects = await projectRepositoryOf(server).fetchTeamProjects(1);

    expect([for (final project in projects) project.id], [6, 5]);
    expect(projects.last.name, '앱');
  });

  test('프로젝트를 만들고 서버가 만든 프로젝트를 돌려준다', () async {
    final server = FakeChatServer();

    final project = await projectRepositoryOf(server).createProject(
      const CreateProjectRequest(teamId: 1, name: '앱', description: '모바일'),
    );

    expect(server.createdProjects.single, {
      'teamId': 1,
      'name': '앱',
      'description': '모바일',
    });
    expect(project.name, '앱');
    expect(server.projects[1]!.single['id'], project.id);
  });
}
