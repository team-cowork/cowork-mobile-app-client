import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../profile/data/repositories/profile_repository.dart';
import '../../../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// 로그인/로그아웃과 앱 시작 시 세션 복원, 사용 중 세션 만료를 담당하는 Bloc.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({AuthRepository? repository, ProfileRepository? profile})
    : _repository = repository ?? AuthRepository(),
      _profile = profile,
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

  /// 로그인 직후 내 프로필을 한 번 읽어 [ProfileStore] 를 채우는 데만 쓴다.
  ///
  /// 없으면 읽지 않는다. 기본값으로 만들면 인증 흐름만 보는 테스트도 실제 dio 를
  /// 세우게 된다.
  final ProfileRepository? _profile;

  Future<void> _onSessionRestored(
    AuthSessionRestored event,
    Emitter<AuthState> emit,
  ) async {
    final restored = await _repository.restoreSession();
    if (restored) await _loadMe();
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
      await _loadMe();
      emit(const AuthState.authenticated());
    } on AuthException catch (e) {
      emit(AuthState.unauthenticated(message: e.message));
    }
  }

  /// 현재 사용자 id 를 [ProfileStore] 에 채운다.
  ///
  /// 회의록의 `내 노트인지` 판별이 여기에 걸려 있어서, 프로필 화면을 한 번도 열지
  /// 않아도 알고 있어야 한다. 실패해도 로그인 자체는 성공이라 상태는 건드리지 않는다.
  Future<void> _loadMe() async {
    try {
      await _profile?.fetchMe();
    } on DioException catch (e) {
      Logger.e('내 프로필 조회 실패', tag: 'Auth', error: e);
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
