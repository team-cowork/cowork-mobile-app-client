import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
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
    _profile?.forgetMe();
    final restored = await _repository.restoreSession();
    if (!restored) {
      emit(const AuthState.unauthenticated());
      return;
    }
    emit(const AuthState.authenticated());
    await _loadMe(emit);
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
    _profile?.forgetMe();
    try {
      await _repository.signIn();
    } catch (e, s) {
      Logger.e('로그인 실패', tag: 'Auth', error: e, stackTrace: s);
      emit(AuthState.unauthenticated(message: _signInErrorMessage(e)));
      return;
    }
    emit(const AuthState.authenticated());
    await _loadMe(emit);
  }

  /// 현재 사용자 id 를 [ProfileStore] 에 채운다.
  ///
  /// 회의록의 `내 노트인지` 판별이 여기에 걸려 있어서, 프로필 화면을 한 번도 열지
  /// 않아도 알고 있어야 한다. 화면을 이 응답까지 붙잡지 않도록 로그인 상태를 먼저
  /// 내보낸 뒤 읽는다. 그동안은 id 를 몰라 내 회의록도 편집 버튼이 안 보인다.
  ///
  /// 실패는 원인에 따라 다르게 다룬다.
  /// - 404: 계정이 없어졌다. 로그인을 유지할 이유가 없어 로그아웃한다.
  /// - 401: 토큰 갱신은 `AuthInterceptor` 가 맡고, 갱신마저 실패하면
  ///   [_onSessionExpired] 가 로그아웃시킨다.
  /// - 그 밖(네트워크·5xx·깨진 응답): 잠깐의 장애일 수 있어 로그인은 유지한다.
  ///   서버가 흔들릴 때마다 로그인 화면으로 보내면 안 되기 때문이다.
  Future<void> _loadMe(Emitter<AuthState> emit) async {
    try {
      await _profile?.fetchMe();
    } on DioException catch (e, s) {
      Logger.e('내 프로필 조회 실패', tag: 'Auth', error: e, stackTrace: s);
      if (e.response?.statusCode == 404 && state is Authenticated) {
        await _repository.signOut();
        emit(
          const AuthState.unauthenticated(
            message: '계정 정보를 찾을 수 없습니다. 다시 로그인해 주세요.',
          ),
        );
      }
    } catch (e, s) {
      Logger.e('내 프로필 응답 처리 실패', tag: 'Auth', error: e, stackTrace: s);
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
