import 'package:equatable/equatable.dart';

import '../../profile/domain/profile_entity.dart';
import 'enums/chat_avatar_color.dart';
import 'enums/dm_presence.dart';

class DirectMessagePreview extends Equatable {
  const DirectMessagePreview({
    required this.profile,
    required this.avatarColor,
    required this.presence,
    required this.lastMessage,
    required this.timestamp,
    this.isPinned = false,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isTyping = false,
  });

  final ProfileEntity profile;
  final ChatAvatarColor avatarColor;
  final DmPresence presence;
  final String lastMessage;
  final String timestamp;
  final bool isPinned;
  final int unreadCount;
  final bool isMuted;
  final bool isTyping;

  @override
  List<Object?> get props => [
    profile,
    avatarColor,
    presence,
    lastMessage,
    timestamp,
    isPinned,
    unreadCount,
    isMuted,
    isTyping,
  ];
}
