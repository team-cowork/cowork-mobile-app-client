import 'package:equatable/equatable.dart';

import 'enums/chat_avatar_color.dart';

class ChannelMember extends Equatable {
  const ChannelMember({
    required this.id,
    required this.name,
    required this.avatarInitial,
    required this.role,
    required this.avatarColor,
    required this.isOnline,
    this.isOwner = false,
  });

  final String id;
  final String name;
  final String avatarInitial;
  final String role;
  final ChatAvatarColor avatarColor;
  final bool isOnline;
  final bool isOwner;

  @override
  List<Object?> get props => [
    id,
    name,
    avatarInitial,
    role,
    avatarColor,
    isOnline,
    isOwner,
  ];
}
