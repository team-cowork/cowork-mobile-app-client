import 'package:cowork_app/core/presentation/auth_gate.dart';
import 'package:cowork_app/network/dev_http_overrides.dart';
import 'package:cowork_app/feature/auth/data/dgsm_oauth_config.dart';
import 'package:cowork_app/feature/auth/presentation/viewModels/auth_bloc.dart';
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
    return BlocProvider(
      create: (_) => AuthBloc()..add(const AuthEvent.sessionRestored()),
      child: MaterialApp(
        title: 'cowork',
        debugShowCheckedModeBanner: false,
        // 디자인이 다크 전용이라 시스템 설정과 무관하게 다크로 고정한다.
        theme: AppTheme.dark(),
        home: const AuthGate(),
      ),
    );
  }
}
