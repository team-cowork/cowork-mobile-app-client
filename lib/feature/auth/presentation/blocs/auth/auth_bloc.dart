import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// 로그인/로그아웃과 앱 시작 시 세션 복원, 사용 중 세션 만료를 담당하는 Bloc.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({AuthRepository? repository})
    : _repository = repository ?? AuthRepository(),
      super(const AuthState.unknown()) {
    on<AuthSessionRestored>(_onSessionRestored);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    _expiredSubscription = _repository.sessionExpired.listen(
      (_) => add(const AuthEvent.sessionExpired()),
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<void> _expiredSubscription;

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

  /// 로그인된 동안만 반응한다. 앱 시작 때 복원 실패는 [_onSessionRestored] 가 이미
  /// 로그아웃 상태로 보낸다.
  void _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) {
    if (state is! Authenticated) return;
    emit(
      const AuthState.unauthenticated(message: '로그인이 만료되었습니다. 다시 로그인해 주세요.'),
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

  @override
  Future<void> close() async {
    await _expiredSubscription.cancel();
    return super.close();
  }
}
