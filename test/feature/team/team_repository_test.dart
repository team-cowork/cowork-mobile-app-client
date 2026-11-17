import 'package:cowork_app/feature/team/domain/enums/invite_duration.dart';
import 'package:dio/dio.dart';
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

  group('초대 코드로 가입', () {
    test('가입한 팀 id 를 돌려준다', () async {
      final server = FakeChatServer()
        ..joinableTeams['aB3xK9mZ'] = {'id': 7, 'name': '새 팀'};

      final joined = await teamRepositoryOf(server).joinTeam('aB3xK9mZ');

      expect(joined.teamId, 7);
      expect(server.requests.last, 'POST /team/teams/join/aB3xK9mZ');
    });

    test('코드에 / 가 섞여도 다른 경로로 새지 않는다', () async {
      final server = FakeChatServer()
        ..joinableTeams['a/../b'] = {'id': 7, 'name': '새 팀'};

      await teamRepositoryOf(server).joinTeam('a/../b');

      expect(server.requests.last, 'POST /team/teams/join/a%2F..%2Fb');
    });

    test('서버가 거절하면 DioException 을 그대로 던진다', () async {
      final server = FakeChatServer()
        ..failJoin = const ServerFailure(410, '만료된 초대 링크입니다.');

      await expectLater(
        teamRepositoryOf(server).joinTeam('expired'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            410,
          ),
        ),
      );
    });
  });

  group('초대 코드', () {
    test('기간을 서버 값으로 보내고 만든 코드를 돌려준다', () async {
      final server = FakeChatServer();

      final invite = await teamRepositoryOf(
        server,
      ).createInvite(1, InviteDuration.sevenDays);

      expect(invite.inviteCode, isNotEmpty);
      expect(invite.duration, InviteDuration.sevenDays);
      expect(invite.expired, isFalse);
      expect(server.requests.last, 'POST /team/teams/1/invites');
      expect(server.invites[1]!.single['duration'], '7d');
    });

    test('오프셋 없는 시각은 UTC 로 읽어 기기 시간으로 바꾼다', () async {
      // dev 서버가 실제로 준 형식이다. 소수점 아래가 9자리(나노초)까지 온다.
      final server = FakeChatServer()
        ..invites[1] = [
          {
            'inviteCode': 'abc',
            'duration': '1d',
            'expiresAt': '2026-11-18T03:00:00.945754019',
            'expired': false,
            'createdAt': '2026-11-17T03:00:00.98578808',
          },
        ];

      final [invite] = await teamRepositoryOf(server).fetchInvites(1);

      expect(
        invite.expiresAt,
        DateTime.utc(2026, 11, 18, 3, 0, 0, 945, 754).toLocal(),
      );
      expect(invite.expiresAt!.isUtc, isFalse);
    });

    test('기간이 never 면 만료 시각이 없고, 모르는 기간은 null 로 읽는다', () async {
      final server = FakeChatServer()
        ..invites[1] = [
          {'inviteCode': 'a', 'duration': 'never', 'expiresAt': null},
          {'inviteCode': 'b', 'duration': '90d', 'expiresAt': null},
        ];

      final invites = await teamRepositoryOf(server).fetchInvites(1);

      expect(
        [for (final i in invites) (i.inviteCode, i.duration, i.expiresAt)],
        [('a', InviteDuration.never, null), ('b', null, null)],
      );
    });

    test('무효화한다', () async {
      final server = FakeChatServer()
        ..invites[1] = [
          {'inviteCode': 'abc', 'duration': '7d', 'expired': false},
        ];

      await teamRepositoryOf(server).revokeInvite(1, 'abc');

      expect(server.requests.last, 'DELETE /team/teams/1/invites/abc');
      expect(server.invites[1]!.single['expired'], isTrue);
    });

    test('이미 없는 코드(404)를 무효화하면 성공으로 본다', () async {
      final server = FakeChatServer()..failRevoke = const ServerFailure(404);

      await teamRepositoryOf(server).revokeInvite(1, 'gone');
    });

    test('무효화 권한이 없으면(403) 던진다', () async {
      final server = FakeChatServer()..failRevoke = const ServerFailure(403);

      await expectLater(
        teamRepositoryOf(server).revokeInvite(1, 'abc'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('멤버', () {
    test('멤버 사용자 id 를 읽는다', () async {
      final server = FakeChatServer()..members[1] = [3, 4];

      final members = await teamRepositoryOf(server).fetchMembers(1);

      expect([for (final m in members) m.userId], [3, 4]);
    });

    test('바로 초대는 사용자 id 목록을 보낸다', () async {
      final server = FakeChatServer();

      await teamRepositoryOf(server).inviteMembers(1, [5, 6]);

      expect(server.requests.last, 'POST /team/teams/1/members');
      expect(server.invitedMembers.single, {
        'userIds': [5, 6],
      });
    });
  });
}
