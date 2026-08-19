import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../../profile/data/profile_repository.dart';
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
  AuthBloc({AuthRepository? repository, ProfileRepository? profile})
    : _repository = repository ?? AuthRepository(),
      super(const AuthState.unknown()) {
    _profile = profile ?? ProfileRepository(_repository);
    on<AuthSessionRestored>(_onSessionRestored);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final AuthRepository _repository;

  /// 로그인 직후 내 프로필을 한 번 읽어 [ProfileStore] 를 채우는 데만 쓴다.
  late final ProfileRepository _profile;

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
      await _profile.fetchMe();
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
}
