import 'package:equatable/equatable.dart';

import 'enums/channel_type.dart';

/// 사이드바의 채널 그룹(카테고리) 하나.
class ChannelGroup extends Equatable {
  const ChannelGroup({
    required this.name,
    required this.channels,
    this.projectId,
  });

  /// 그룹 이름 (예: 디자인).
  final String name;

  final List<Channel> channels;

  /// 이 그룹이 묶는 프로젝트. 어느 프로젝트에도 속하지 않은 채널 그룹이면 null.
  final int? projectId;

  @override
  List<Object?> get props => [name, channels, projectId];
}

/// 채널 그룹 안의 개별 채널.
class Channel extends Equatable {
  const Channel({
    required this.id,
    required this.name,
    required this.type,
    this.projectId,
  });

  final String id;

  /// 표시 이름 (예: 채팅, 깃허브 웹훅).
  final String name;

  final ChannelType type;

  /// 채널이 속한 프로젝트(카테고리). 속하지 않으면 null.
  final int? projectId;

  @override
  List<Object?> get props => [id, name, type, projectId];
}
