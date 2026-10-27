import 'dart:async';

import 'package:cowork_app/app/auth_gate.dart';
import 'package:cowork_app/core/network/chat_socket.dart';
import 'package:cowork_app/feature/auth/data/auth_repository.dart';
import 'package:cowork_app/feature/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:cowork_app/feature/auth/presentation/views/login_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../feature/channel/chat_test_server.dart';

/// 앱 시작 때 세션이 복원되고, 만료 알림은 테스트가 보낸다.
class _FakeAuthRepository extends Fake implements AuthRepository {
  final expired = StreamController<void>.broadcast();

  @override
  Stream<void> get sessionExpired => expired.stream;

  @override
  Future<bool> restoreSession() async => true;
}

void main() {
  testWidgets('세션이 만료되면 위에 쌓인 화면과 시트를 걷고 로그인 화면과 사유를 보여준다', (tester) async {
    final repository = _FakeAuthRepository();
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const AuthGate()),
        GoRoute(
          path: '/pushed',
          builder: (_, _) => const Scaffold(body: Text('위에 쌓인 화면')),
        ),
      ],
    );
    final server = FakeChatServer();
    // 로그인되면 메인 셸이 채널 탭을 띄우므로 팀·채널 저장소와 소켓이 있어야 한다.
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: teamRepositoryOf(server)),
          RepositoryProvider.value(value: channelRepositoryOf(server)),
          RepositoryProvider<ChatSocket>.value(value: FakeChatSocket()),
        ],
        child: BlocProvider(
          create: (_) =>
              AuthBloc(repository: repository)
                ..add(const AuthEvent.sessionRestored()),
          child: MaterialApp.router(
            theme: AppTheme.dark(),
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(router.push('/pushed'));
    await tester.pumpAndSettle();
    unawaited(
      showModalBottomSheet<void>(
        context: tester.element(find.text('위에 쌓인 화면')),
        builder: (_) => const Text('시트'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('시트'), findsOneWidget);

    repository.expired.add(null);
    await tester.pumpAndSettle();

    expect(find.text('위에 쌓인 화면'), findsNothing);
    expect(find.text('시트'), findsNothing);
    expect(router.state.uri.path, '/');
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('로그인이 만료되었습니다. 다시 로그인해 주세요.'), findsOneWidget);
  });
}
