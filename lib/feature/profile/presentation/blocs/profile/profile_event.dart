part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  /// 프로필 데이터 로드를 요청한다.
  const factory ProfileEvent.requested() = ProfileRequested;

  @override
  List<Object?> get props => [];
}

final class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}
