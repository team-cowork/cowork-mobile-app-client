import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/logger.dart';
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
    } catch (e, s) {
      Logger.e('로그인 실패', tag: 'Auth', error: e, stackTrace: s);
      emit(AuthState.unauthenticated(message: _signInErrorMessage(e)));
    }
  }

  static String _signInErrorMessage(Object error) => switch (error) {
    DioException() => dioErrorMessage(error),
    AuthFailure(:final kind, :final detail) => switch (kind) {
      AuthFailureKind.canceled => '로그인이 취소되었습니다.',
      AuthFailureKind.browserFailed => '브라우저 인증에 실패했습니다.',
      AuthFailureKind.stateMismatch => '인증 응답을 신뢰할 수 없어 로그인을 중단했습니다.',
      AuthFailureKind.codeMissing => detail ?? '인가 코드를 받지 못했습니다.',
      AuthFailureKind.invalidTokenResponse => '토큰 응답 형식이 올바르지 않습니다.',
    },
    _ => '로그인에 실패했습니다.',
  };

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
