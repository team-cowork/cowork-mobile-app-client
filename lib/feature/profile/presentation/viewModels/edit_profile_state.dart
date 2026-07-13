part of 'edit_profile_bloc.dart';

sealed class EditProfileState extends Equatable {
  const EditProfileState();

  const factory EditProfileState.initial() = EditProfileInitial;
  const factory EditProfileState.loading() = EditProfileLoading;
  const factory EditProfileState.success(EditProfile profile) =
      EditProfileSuccess;
  const factory EditProfileState.failure() = EditProfileFailure;

  @override
  List<Object?> get props => [];
}

final class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

final class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

final class EditProfileSuccess extends EditProfileState {
  const EditProfileSuccess(this.profile);

  final EditProfile profile;

  @override
  List<Object?> get props => [profile];
}

final class EditProfileFailure extends EditProfileState {
  const EditProfileFailure();
}
