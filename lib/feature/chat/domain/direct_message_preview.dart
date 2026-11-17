import 'package:equatable/equatable.dart';

import '../../../shared/domain/enums/chat_avatar_color.dart';
import '../../../shared/domain/profile_entity.dart';
import 'enums/dm_presence.dart';

class DirectMessagePreview extends Equatable {
  const DirectMessagePreview({
    required this.channelId,
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

  /// 대화에 쓰는 DM 채널 id. 누르면 이 채널의 대화 화면으로 간다.
  final int channelId;

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
    channelId,
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
