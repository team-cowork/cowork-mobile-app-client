import 'package:equatable/equatable.dart';

import 'enums/channel_type.dart';

/// 사이드바의 채널 그룹(카테고리) 하나.
class ChannelGroup extends Equatable {
  const ChannelGroup({required this.name, required this.channels});

  /// 그룹 이름 (예: 디자인).
  final String name;

  final List<Channel> channels;

  @override
  List<Object?> get props => [name, channels];
}

/// 채널 그룹 안의 개별 채널.
class Channel extends Equatable {
  const Channel({required this.id, required this.name, required this.type});

  final String id;

  /// 표시 이름 (예: 채팅, 깃허브 웹훅).
  final String name;

  final ChannelType type;

  @override
  List<Object?> get props => [id, name, type];
}
