import 'package:equatable/equatable.dart';

import 'channel_member.dart';
import 'channel_notification.dart';

class ChannelSettings extends Equatable {
  const ChannelSettings({
    required this.name,
    required this.description,
    required this.isPrivate,
    required this.notification,
    required this.memberPreview,
    required this.memberCount,
  });

  final String name;
  final String description;
  final bool isPrivate;

  /// 이 채널에 내가 정해 둔 알림 설정.
  final ChannelNotification notification;

  /// 멤버 목록 행에 겹쳐 보여줄 아바타 미리보기 (최대 4명).
  final List<ChannelMember> memberPreview;
  final int memberCount;

  ChannelSettings copyWith({
    String? name,
    String? description,
    bool? isPrivate,
    ChannelNotification? notification,
  }) {
    return ChannelSettings(
      name: name ?? this.name,
      description: description ?? this.description,
      isPrivate: isPrivate ?? this.isPrivate,
      notification: notification ?? this.notification,
      memberPreview: memberPreview,
      memberCount: memberCount,
    );
  }

  @override
  List<Object?> get props => [
    name,
    description,
    isPrivate,
    notification,
    memberPreview,
    memberCount,
  ];
}
