import 'package:equatable/equatable.dart';

import '../../profile/domain/profile_entity.dart';
import 'chat_attachment.dart';
import 'enums/chat_avatar_color.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.avatarColor,
    required this.timestamp,
    required this.text,
    this.attachments = const [],
  });

  final String id;
  final ProfileEntity author;
  final ChatAvatarColor avatarColor;
  final String timestamp;
  final String text;

  /// 붙은 파일. 파일만 보낸 메시지는 [text] 가 비어 있을 수 있다.
  final List<ChatAttachment> attachments;

  @override
  List<Object?> get props => [
    id,
    author,
    avatarColor,
    timestamp,
    text,
    attachments,
  ];
}
