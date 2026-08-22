import 'package:equatable/equatable.dart';

import '../../profile/domain/profile_entity.dart';
import 'enums/chat_avatar_color.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.avatarColor,
    required this.timestamp,
    required this.text,
  });

  final String id;
  final ProfileEntity author;
  final ChatAvatarColor avatarColor;
  final String timestamp;
  final String text;

  @override
  List<Object?> get props => [id, author, avatarColor, timestamp, text];
}
