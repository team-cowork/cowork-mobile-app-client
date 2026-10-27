import 'dart:async';

import 'package:cowork_app/feature/auth/data/auth_repository.dart';
import 'package:cowork_app/feature/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// 복원 결과와 세션 만료 알림을 테스트가 정한다.
class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository({required this.restores});

  final bool restores;
  final expired = StreamController<void>.broadcast();

  @override
  Stream<void> get sessionExpired => expired.stream;

  @override
  Future<bool> restoreSession() async => restores;
}

void main() {
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
}
