import 'package:equatable/equatable.dart';

import '../../profile/domain/profile_entity.dart';
import 'enums/chat_avatar_color.dart';
import 'enums/dm_presence.dart';

class DmPresenceEntry extends Equatable {
  const DmPresenceEntry({
    required this.profile,
    required this.avatarColor,
    required this.presence,
  });

  final ProfileEntity profile;
  final ChatAvatarColor avatarColor;
  final DmPresence presence;

  @override
  List<Object?> get props => [profile, avatarColor, presence];
}
