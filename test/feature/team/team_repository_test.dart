import 'package:flutter_test/flutter_test.dart';

import '../channel/chat_test_server.dart';

void main() {
  test('팀 목록을 읽는다', () async {
    final teams = await teamRepositoryOf(FakeChatServer()).fetchMyTeams();

    expect(
      [for (final team in teams) (team.id, team.name)],
      [(1, '코워크'), (2, '디자인팀')],
    );
  });
}
