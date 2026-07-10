part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  const factory ProfileState.initial() = ProfileInitial;
  const factory ProfileState.loading() = ProfileLoading;
  const factory ProfileState.success(Profile profile) = ProfileSuccess;
  const factory ProfileState.failure() = ProfileFailure;

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileSuccess extends ProfileState {
  const ProfileSuccess(this.profile);

  final Profile profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure();
}
