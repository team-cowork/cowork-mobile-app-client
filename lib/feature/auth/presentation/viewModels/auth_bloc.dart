import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';

part 'auth_event.dart';

/// 앱 전역 인증 상태.
///
/// ponytail: `AsyncState<T>` 를 쓰지 않는다. 로그아웃은 "실패"가 아니라 정상 상태라
/// initial/loading/success/failure 로는 표현이 어긋난다.
sealed class AuthState extends Equatable {
  const AuthState();

  /// 저장된 세션 복원 전. 로딩 화면을 띄운다.
  const factory AuthState.unknown() = AuthUnknown;

  /// 브라우저 인증 진행 중.
  const factory AuthState.inProgress() = AuthInProgress;

  /// 로그인됨.
  const factory AuthState.authenticated() = Authenticated;

  /// 로그아웃 상태. [message] 가 있으면 직전 로그인 시도가 실패한 것이다.
  const factory AuthState.unauthenticated({String? message}) = Unauthenticated;

  @override
  List<Object?> get props => [];
}

final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class AuthInProgress extends AuthState {
  const AuthInProgress();
}

final class Authenticated extends AuthState {
  const Authenticated();
}

final class Unauthenticated extends AuthState {
  const Unauthenticated({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// 로그인/로그아웃과 앱 시작 시 세션 복원을 담당하는 Bloc.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({AuthRepository? repository})
    : _repository = repository ?? AuthRepository(),
      super(const AuthState.unknown()) {
    on<AuthSessionRestored>(_onSessionRestored);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final AuthRepository _repository;

  Future<void> _onSessionRestored(
    AuthSessionRestored event,
    Emitter<AuthState> emit,
  ) async {
    final restored = await _repository.restoreSession();
    emit(
      restored
          ? const AuthState.authenticated()
          : const AuthState.unauthenticated(),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.inProgress());
    try {
      await _repository.signIn();
      emit(const AuthState.authenticated());
    } on AuthException catch (e) {
      emit(AuthState.unauthenticated(message: e.message));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.signOut();
    emit(const AuthState.unauthenticated());
  }
}
