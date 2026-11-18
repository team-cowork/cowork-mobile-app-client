import '../../../team/data/model/responses/team_member_response.dart';
import '../../domain/channel_member.dart';

/// 서버 팀 멤버 역할(`OWNER` / `ADMIN` / `MEMBER`)을 앱 역할로. 팀 멤버를 못 읽었거나
/// 모르는 값이면 일반 멤버로 본다.
ChannelMemberRole channelMemberRoleOf(TeamMemberResponse? member) =>
    switch (member?.role) {
      'OWNER' => ChannelMemberRole.owner,
      'ADMIN' => ChannelMemberRole.admin,
      _ => ChannelMemberRole.member,
    };

/// 멤버가 팀에서 받은 커스텀 역할 이름. 모든 멤버에게 자동으로 붙는 기본 역할과 이름이
/// 빈 역할은 뺀다.
List<String> channelMemberRoleNamesOf(TeamMemberResponse? member) => [
  for (final role in member?.roles ?? const [])
    if (!role.isDefault && role.name.isNotEmpty) role.name,
];
