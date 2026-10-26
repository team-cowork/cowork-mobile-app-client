import 'package:cowork_app/core/presentation/app_router.dart';
import 'package:cowork_app/core/utils/logger.dart';
import 'package:cowork_app/network/dev_http_overrides.dart';
import 'package:cowork_app/feature/auth/data/auth_repository.dart';
import 'package:cowork_app/feature/auth/data/dgsm_oauth_config.dart';
import 'package:cowork_app/feature/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/team/data/repositories/team_repository.dart';
import 'package:cowork_app/feature/profile/data/repositories/github_repository.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:cowork_app/feature/setting/data/preference_repository.dart';
import 'package:cowork_app/feature/setting/data/push_repository.dart';
import 'package:cowork_app/network/chat_socket.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DgsmOAuthConfig.assertConfigured();
  DevHttpOverrides.installIfDebug();
  await _initFirebase();
  runApp(const CoworkApp());
}

/// Firebase 설정 파일(`google-services.json`)은 커밋하지 않는다. 옵션 없이 부르면
/// 네이티브 설정 파일을 읽는데, 파일 없이 빌드한 PC 에서는 실패한다. 그래도 앱은
/// 띄우고 푸시만 못 쓰게 둔다([FirebasePushDevice]).
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e, s) {
    Logger.e('Firebase 초기화 실패. 푸시 알림을 쓸 수 없다', error: e, stackTrace: s);
  }
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
        RepositoryProvider(
          create: (context) => TeamRepository(context.read<AuthRepository>()),
        ),
        RepositoryProvider(
          create: (context) =>
              ChannelRepository(context.read<AuthRepository>()),
        ),
        RepositoryProvider(
          create: (context) =>
              MessageRepository(context.read<AuthRepository>()),
        ),
        // 채팅 서버 소켓 연결은 앱에 하나만 두고 화면들이 나눠 쓴다.
        RepositoryProvider(
          create: (context) => ChatSocket(context.read<AuthRepository>()),
          dispose: (socket) => socket.dispose(),
        ),
        RepositoryProvider(
          create: (context) =>
              PreferenceRepository(context.read<AuthRepository>()),
        ),
        RepositoryProvider(
          create: (context) => PushRepository(context.read<AuthRepository>()),
        ),
      ],
      child: BlocProvider(
        create: (context) =>
            AuthBloc(repository: context.read<AuthRepository>())
              ..add(const AuthEvent.sessionRestored()),
        child: MaterialApp.router(
          title: 'cowork',
          debugShowCheckedModeBanner: false,
          // 디자인이 다크 전용이라 시스템 설정과 무관하게 다크로 고정한다.
          theme: AppTheme.dark(),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
