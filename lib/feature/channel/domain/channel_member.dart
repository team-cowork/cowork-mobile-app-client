import 'package:equatable/equatable.dart';

import '../../../shared/domain/enums/chat_avatar_color.dart';
import '../../../shared/domain/profile_entity.dart';

/// 채널을 읽을 수 있는 사용자 한 명.
class ChannelMember extends Equatable {
  const ChannelMember({
    required this.profile,
    required this.avatarColor,
    this.role = ChannelMemberRole.member,
    this.roleNames = const [],
  });

  final ProfileEntity profile;
  final ChatAvatarColor avatarColor;

  /// 팀에서의 역할. 팀 멤버를 못 읽었으면 [ChannelMemberRole.member] 로 둔다.
  final ChannelMemberRole role;

  /// 팀에서 받은 커스텀 역할 이름. 모든 멤버에게 자동으로 붙는 기본 역할은 뺀다.
  final List<String> roleNames;

  @override
  List<Object?> get props => [profile, avatarColor, role, roleNames];
}

/// 팀 멤버의 기본 역할.
enum ChannelMemberRole { owner, admin, member }
