import 'package:equatable/equatable.dart';

import 'channel_member.dart';

class ChannelSettings extends Equatable {
  const ChannelSettings({
    required this.name,
    required this.description,
    required this.isPrivate,
    required this.notificationLabel,
    required this.isMuted,
    required this.memberPreview,
    required this.memberCount,
  });

  final String name;
  final String description;
  final bool isPrivate;
  final String notificationLabel;
  final bool isMuted;

  /// 멤버 목록 행에 겹쳐 보여줄 아바타 미리보기 (최대 4명).
  final List<ChannelMember> memberPreview;
  final int memberCount;

  ChannelSettings copyWith({bool? isPrivate, bool? isMuted}) {
    return ChannelSettings(
      name: name,
      description: description,
      isPrivate: isPrivate ?? this.isPrivate,
      notificationLabel: notificationLabel,
      isMuted: isMuted ?? this.isMuted,
      memberPreview: memberPreview,
      memberCount: memberCount,
    );
  }

  @override
  List<Object?> get props => [
    name,
    description,
    isPrivate,
    notificationLabel,
    isMuted,
    memberPreview,
    memberCount,
  ];
}
