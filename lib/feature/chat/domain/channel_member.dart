import 'package:equatable/equatable.dart';

import '../../profile/domain/profile_entity.dart';
import 'enums/chat_avatar_color.dart';

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
