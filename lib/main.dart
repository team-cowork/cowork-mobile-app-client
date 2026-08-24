import 'package:cowork_app/core/presentation/auth_gate.dart';
import 'package:cowork_app/network/dev_http_overrides.dart';
import 'package:cowork_app/feature/auth/data/auth_repository.dart';
import 'package:cowork_app/feature/auth/data/dgsm_oauth_config.dart';
import 'package:cowork_app/feature/auth/presentation/viewModels/auth_bloc.dart';
import 'package:cowork_app/feature/profile/data/github_repository.dart';
import 'package:cowork_app/feature/profile/data/profile_repository.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DgsmOAuthConfig.assertConfigured();
  DevHttpOverrides.installIfDebug();
  runApp(const CoworkApp());
}

class CoworkApp extends StatelessWidget {
  const CoworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 인증이 필요한 API 는 [AuthRepository] 가 메모리에 들고 있는 access token 을
    // 써야 한다. 화면마다 새로 만들면 토큰 없는 인스턴스가 생기므로 여기서 한 번만
    // 만들어 내려보낸다.
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(
          create: (context) =>
              ProfileRepository(context.read<AuthRepository>()),
        ),
        RepositoryProvider(create: (_) => GithubRepository()),
      ],
      child: BlocProvider(
        create: (context) =>
            AuthBloc(repository: context.read<AuthRepository>())
              ..add(const AuthEvent.sessionRestored()),
        child: MaterialApp(
          title: 'cowork',
          debugShowCheckedModeBanner: false,
          // 디자인이 다크 전용이라 시스템 설정과 무관하게 다크로 고정한다.
          theme: AppTheme.dark(),
          home: const AuthGate(),
        ),
      ),
    );
  }
}
