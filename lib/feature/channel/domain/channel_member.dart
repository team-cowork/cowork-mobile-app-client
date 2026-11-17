import 'package:equatable/equatable.dart';

import '../../../shared/domain/enums/chat_avatar_color.dart';
import '../../../shared/domain/profile_entity.dart';

/// 채널을 읽을 수 있는 사용자 한 명.
class ChannelMember extends Equatable {
  const ChannelMember({required this.profile, required this.avatarColor});

  final ProfileEntity profile;
  final ChatAvatarColor avatarColor;

  @override
  List<Object?> get props => [profile, avatarColor];
}
