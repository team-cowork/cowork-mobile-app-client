part of 'edit_profile_bloc.dart';

sealed class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  /// 편집할 프로필 데이터 로드를 요청한다.
  const factory EditProfileEvent.requested() = EditProfileRequested;

  @override
  List<Object?> get props => [];
}

final class EditProfileRequested extends EditProfileEvent {
  const EditProfileRequested();
}
