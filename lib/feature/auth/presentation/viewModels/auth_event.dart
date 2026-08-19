part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  /// 앱 시작 시 저장된 refresh token 으로 세션 복원을 시도한다.
  const factory AuthEvent.sessionRestored() = AuthSessionRestored;

  /// DataGSM 로그인 버튼을 눌렀다.
  const factory AuthEvent.signInRequested() = AuthSignInRequested;

  const factory AuthEvent.signOutRequested() = AuthSignOutRequested;

  @override
  List<Object?> get props => [];
}

final class AuthSessionRestored extends AuthEvent {
  const AuthSessionRestored();
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
