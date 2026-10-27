import 'package:equatable/equatable.dart';

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

  @override
  List<Object?> get props => [id, name, avatarInitial, avatarUrl];
}
