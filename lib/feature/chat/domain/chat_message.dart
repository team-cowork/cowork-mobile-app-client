import 'package:equatable/equatable.dart';

import 'enums/chat_avatar_color.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.authorName,
    required this.authorInitial,
    required this.avatarColor,
    required this.timestamp,
    required this.text,
  });

  final String id;
  final String authorName;
  final String authorInitial;
  final ChatAvatarColor avatarColor;
  final String timestamp;
  final String text;

  @override
  List<Object?> get props => [
    id,
    authorName,
    authorInitial,
    avatarColor,
    timestamp,
    text,
  ];
}
