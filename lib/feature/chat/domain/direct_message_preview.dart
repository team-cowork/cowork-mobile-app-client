import 'package:equatable/equatable.dart';

import '../../../shared/domain/enums/chat_avatar_color.dart';
import '../../../shared/domain/profile_entity.dart';

/// DM 목록의 대화 한 줄.
class DirectMessagePreview extends Equatable {
  const DirectMessagePreview({
    required this.channelId,
    required this.profile,
    required this.avatarColor,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
  });

  /// 대화에 쓰는 DM 채널 id. 누르면 이 채널의 대화 화면으로 간다.
  final int channelId;

  /// 대화 상대.
  final ProfileEntity profile;
  final ChatAvatarColor avatarColor;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;

  @override
  List<Object?> get props => [
    channelId,
    profile,
    avatarColor,
    lastMessage,
    timestamp,
    unreadCount,
  ];
}
