import 'package:equatable/equatable.dart';

import '../../../shared/domain/enums/chat_avatar_color.dart';
import '../../../shared/domain/profile_entity.dart';

class ChannelMember extends Equatable {
  const ChannelMember({
    required this.profile,
    required this.role,
    required this.avatarColor,
    required this.isOnline,
    this.isOwner = false,
  });

  final ProfileEntity profile;
  final String role;
  final ChatAvatarColor avatarColor;
  final bool isOnline;
  final bool isOwner;

  @override
  List<Object?> get props => [profile, role, avatarColor, isOnline, isOwner];
}
