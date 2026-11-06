import 'package:cowork_app/app/app_router.dart';
import 'package:cowork_app/core/network/chat_socket.dart';
import 'package:cowork_app/core/network/dev_http_overrides.dart';
import 'package:cowork_app/core/utils/logger.dart';
import 'package:cowork_app/feature/auth/data/auth_repository.dart';
import 'package:cowork_app/feature/auth/data/dgsm_oauth_config.dart';
import 'package:cowork_app/feature/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:cowork_app/feature/channel/data/repositories/channel_repository.dart';
import 'package:cowork_app/feature/chat/data/repositories/message_repository.dart';
import 'package:cowork_app/feature/notifications/data/notification_stream.dart';
import 'package:cowork_app/feature/notifications/data/repositories/notification_repository.dart';
import 'package:cowork_app/feature/profile/data/repositories/github_repository.dart';
import 'package:cowork_app/feature/profile/data/repositories/profile_repository.dart';
import 'package:cowork_app/feature/search/data/repositories/recent_search_repository.dart';
import 'package:cowork_app/feature/search/data/repositories/search_repository.dart';
import 'package:cowork_app/feature/setting/data/preference_repository.dart';
import 'package:cowork_app/feature/setting/data/push_repository.dart';
import 'package:cowork_app/feature/team/data/repositories/team_repository.dart';
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
        RepositoryProvider(
          create: (context) => SearchRepository(context.read<AuthRepository>()),
        ),
        RepositoryProvider(create: (_) => RecentSearchRepository()),
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
        // 알림 SSE 는 로그인한 동안 앱 전체에서 하나를 열어 두고 받은 알림을 쌓는다.
        RepositoryProvider(
          create: (context) => NotificationRepository(
            NotificationStream(context.read<AuthRepository>()),
          ),
          dispose: (repository) => repository.dispose(),
        ),
      ],
      child: BlocProvider(
        create: (context) =>
            AuthBloc(repository: context.read<AuthRepository>())
              ..add(const AuthEvent.sessionRestored()),
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (previous, current) =>
                  (previous is Authenticated) != (current is Authenticated),
              listener: (context, state) {
                final notifications = context.read<NotificationRepository>();
                if (state is Authenticated) {
                  notifications.start();
                } else {
                  notifications.stop();
                }
              },
            ),
            // 최근 검색어는 사용자 구분 없이 기기에 남으므로, 다음 사람이 보지 않게
            // 로그아웃 상태가 되면 지운다. 앱이 꺼진 동안 세션이 끝나 시작하자마자
            // 로그아웃 상태가 되는 경우(unknown → unauthenticated)도 포함한다.
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (previous, current) =>
                  current is Unauthenticated && previous is! Unauthenticated,
              listener: (context, _) {
                context.read<RecentSearchRepository>().clearAll().catchError((
                  Object e,
                  StackTrace s,
                ) {
                  Logger.e(
                    '최근 검색어 삭제 실패',
                    tag: 'Search',
                    error: e,
                    stackTrace: s,
                  );
                });
              },
            ),
          ],
          child: MaterialApp.router(
            title: 'cowork',
            debugShowCheckedModeBanner: false,
            // 디자인이 다크 전용이라 시스템 설정과 무관하게 다크로 고정한다.
            theme: AppTheme.dark(),
            routerConfig: appRouter,
          ),
        ),
      ),
    );
  }
}
