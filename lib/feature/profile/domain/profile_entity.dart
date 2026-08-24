import 'package:equatable/equatable.dart';

import '../data/profile_store.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.id,
    required this.name,
    required this.avatarInitial,
    this.avatarUrl,
  });

  final int id;
  final String name;
  final String avatarInitial;
  final String? avatarUrl;

  bool get isMine => id == ProfileStore.instance.currentUserId;

  @override
  List<Object?> get props => [id, name, avatarInitial, avatarUrl];
}
