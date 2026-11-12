import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/auth/data/auth_repository.dart';
import 'package:cowork_app/feature/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:cowork_app/feature/profile/data/profile_store.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 복원 결과와 세션 만료 알림을 테스트가 정한다.
class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository({required this.restores, this.signInError});

  final bool restores;

  /// 주면 [signIn] 이 이걸 던진다.
  final Object? signInError;
  final expired = StreamController<void>.broadcast();
  bool signedOut = false;

  @override
  Stream<void> get sessionExpired => expired.stream;

  @override
  Future<bool> restoreSession() async => restores;

  @override
  Future<void> signOut() async => signedOut = true;

  @override
  Future<void> signIn() async {
    if (signInError case final error?) throw error;
  }
}

/// `/users/me` 에 [status] 와 [body] 로 답한다.
class _MeServer implements HttpClientAdapter {
  _MeServer(this.status, this.body);

  final int status;
  final Object? body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode({'status': 'OK', 'code': status, 'data': body}),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

ProfileRepository _profileAnswering(int status, [Object? body]) =>
    ProfileRepository.withDio(
      Dio(BaseOptions(baseUrl: 'https://test'))
        ..httpClientAdapter = _MeServer(status, body),
    );

/// 세션을 복원하고 `/users/me` 응답까지 처리될 때까지 기다린다.
Future<AuthBloc> _restored(
  _FakeAuthRepository repository,
  ProfileRepository profile,
) async {
  final bloc = AuthBloc(repository: repository, profile: profile)
    ..add(const AuthEvent.sessionRestored());
  await pumpEventQueue();
  return bloc;
}

/// [error] 로 로그인이 실패했을 때 로그인 화면에 보여 줄 문구.
Future<String?> _signInMessageOf(Object error) async {
  final bloc = AuthBloc(
    repository: _FakeAuthRepository(restores: false, signInError: error),
  )..add(const AuthEvent.signInRequested());
  await pumpEventQueue();
  final state = bloc.state;
  await bloc.close();
  return state is Unauthenticated ? state.message : null;
}

void main() {
  // 이전 테스트가 채운 id 가 다음 테스트로 새지 않게 한다.
  setUp(() => ProfileStore.instance.currentUserId = null);

  group('로그인 직후 내 프로필', () {
    test('읽으면 내 id 를 채운다', () async {
      final bloc = await _restored(
        _FakeAuthRepository(restores: true),
        _profileAnswering(200, {'id': 7, 'name': '김준혁'}),
      );

      expect(bloc.state, const AuthState.authenticated());
      expect(ProfileStore.instance.currentUserId, 7);
      await bloc.close();
    });

    test('서버 장애로 못 읽으면 로그인은 유지하고, 이전 사용자 id 는 지운다', () async {
      // 이전에 로그인했던 사용자.
      ProfileStore.instance.currentUserId = 99;

      final bloc = await _restored(
        _FakeAuthRepository(restores: true),
        _profileAnswering(503),
      );

      expect(bloc.state, const AuthState.authenticated());
      expect(ProfileStore.instance.currentUserId, isNull);
      await bloc.close();
    });

    test('응답이 깨져도 로그인 상태에 멈추지 않는다', () async {
      final bloc = await _restored(
        _FakeAuthRepository(restores: true),
        _profileAnswering(200, {'id': '숫자가 아닌 id'}),
      );

      expect(bloc.state, const AuthState.authenticated());
      await bloc.close();
    });

    test('계정이 없으면(404) 로그아웃한다', () async {
      final repository = _FakeAuthRepository(restores: true);
      final bloc = await _restored(repository, _profileAnswering(404));

      expect(
        bloc.state,
        const AuthState.unauthenticated(
          message: '계정 정보를 찾을 수 없습니다. 다시 로그인해 주세요.',
        ),
      );
      expect(repository.signedOut, isTrue);
      await bloc.close();
    });
  });

  test('로그인된 동안 세션이 만료되면 사유와 함께 로그아웃 상태가 된다', () async {
    final repository = _FakeAuthRepository(restores: true);
    final bloc = AuthBloc(repository: repository)
      ..add(const AuthEvent.sessionRestored());
    await pumpEventQueue();
    expect(bloc.state, const AuthState.authenticated());

    repository.expired.add(null);
    await pumpEventQueue();

    expect(
      bloc.state,
      const AuthState.unauthenticated(message: '로그인이 만료되었습니다. 다시 로그인해 주세요.'),
    );
    await bloc.close();
  });

  test('로그인 전에 온 만료 알림은 무시한다', () async {
    final repository = _FakeAuthRepository(restores: false);
    final bloc = AuthBloc(repository: repository);

    repository.expired.add(null);
    await pumpEventQueue();
    expect(bloc.state, const AuthState.unknown());

    bloc.add(const AuthEvent.sessionRestored());
    await pumpEventQueue();
    // 앱 시작 때 복원 실패는 사유 없이 로그인 화면으로 간다.
    expect(bloc.state, const AuthState.unauthenticated());
    await bloc.close();
  });

  group('로그인 실패 문구', () {
    test('서버 요청 실패는 공통 규칙(dioErrorMessage)을 따른다', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/auth/token'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/token'),
          statusCode: 503,
        ),
      );
      expect(await _signInMessageOf(error), '(503) 서비스를 잠시 사용할 수 없습니다.');
    });

    test('브라우저를 닫으면 취소 문구를 보여 준다', () async {
      expect(
        await _signInMessageOf(const AuthFailure(AuthFailureKind.canceled)),
        '로그인이 취소되었습니다.',
      );
    });

    test('인가 코드 대신 온 DataGSM 사유를 그대로 보여 준다', () async {
      expect(
        await _signInMessageOf(
          const AuthFailure(
            AuthFailureKind.codeMissing,
            detail: 'access_denied',
          ),
        ),
        'access_denied',
      );
    });

    test('예상하지 못한 예외도 진행 중에 멈추지 않고 기본 문구로 끝난다', () async {
      expect(
        await _signInMessageOf(const FormatException('bad json')),
        '로그인에 실패했습니다.',
      );
    });

    for (final (kind, message) in [
      (AuthFailureKind.browserFailed, '브라우저 인증에 실패했습니다.'),
      (AuthFailureKind.stateMismatch, '인증 응답을 신뢰할 수 없어 로그인을 중단했습니다.'),
      (AuthFailureKind.codeMissing, '인가 코드를 받지 못했습니다.'),
      (AuthFailureKind.invalidTokenResponse, '토큰 응답 형식이 올바르지 않습니다.'),
    ]) {
      test('${kind.name} 는 종류별 기본 문구를 보여 준다', () async {
        expect(await _signInMessageOf(AuthFailure(kind)), message);
      });
    }
  });
}
