import 'package:cowork_app/feature/channel/data/model/channel_member_mapping.dart';
import 'package:cowork_app/feature/channel/domain/channel_member.dart';
import 'package:cowork_app/feature/team/data/model/responses/team_member_response.dart';
import 'package:cowork_app/feature/team/data/model/responses/team_member_role_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('팀 역할', () {
    test('서버 역할 값을 앱 역할로 바꾼다', () {
      expect(
        channelMemberRoleOf(const TeamMemberResponse(userId: 1, role: 'OWNER')),
        ChannelMemberRole.owner,
      );
      expect(
        channelMemberRoleOf(const TeamMemberResponse(userId: 1, role: 'ADMIN')),
        ChannelMemberRole.admin,
      );
      expect(
        channelMemberRoleOf(
          const TeamMemberResponse(userId: 1, role: 'MEMBER'),
        ),
        ChannelMemberRole.member,
      );
    });

    test('모르는 값이거나 팀 멤버를 못 읽었으면 일반 멤버로 본다', () {
      expect(
        channelMemberRoleOf(const TeamMemberResponse(userId: 1, role: 'GUEST')),
        ChannelMemberRole.member,
      );
      expect(channelMemberRoleOf(null), ChannelMemberRole.member);
    });
  });

  group('커스텀 역할 이름', () {
    test('기본 역할과 이름이 빈 역할은 빼고 서버가 준 순서를 지킨다', () {
      const member = TeamMemberResponse(
        userId: 1,
        roles: [
          TeamMemberRoleResponse(name: '디자이너'),
          TeamMemberRoleResponse(name: '팀원', isDefault: true),
          TeamMemberRoleResponse(),
          TeamMemberRoleResponse(name: '리뷰어'),
        ],
      );

      expect(channelMemberRoleNamesOf(member), ['디자이너', '리뷰어']);
    });

    test('팀 멤버를 못 읽었으면 비어 있다', () {
      expect(channelMemberRoleNamesOf(null), isEmpty);
    });
  });
}
