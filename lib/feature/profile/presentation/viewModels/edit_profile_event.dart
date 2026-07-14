part of 'edit_profile_bloc.dart';

sealed class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  /// 편집할 프로필 데이터 로드를 요청한다.
  const factory EditProfileEvent.requested() = EditProfileRequested;

  /// 편집한 값 저장을 요청한다.
  const factory EditProfileEvent.submitted({
    required String name,
    required String username,
    required String statusMessage,
    required String bio,
    String? localAvatarPath,
  }) = EditProfileSubmitted;

  @override
  List<Object?> get props => [];
}

final class EditProfileRequested extends EditProfileEvent {
  const EditProfileRequested();
}

final class EditProfileSubmitted extends EditProfileEvent {
  const EditProfileSubmitted({
    required this.name,
    required this.username,
    required this.statusMessage,
    required this.bio,
    this.localAvatarPath,
  });

  final String name;
  final String username;
  final String statusMessage;
  final String bio;
  final String? localAvatarPath;

  @override
  List<Object?> get props => [
    name,
    username,
    statusMessage,
    bio,
    localAvatarPath,
  ];
}
