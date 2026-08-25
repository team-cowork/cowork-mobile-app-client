import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

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
