import 'package:cowork_app/core/presentation/main_shell.dart';
import 'package:cowork_app/feature/auth/presentation/views/login_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'cowork',
      debugShowCheckedModeBanner: false,
      // 디자인이 다크 전용이라 시스템 설정과 무관하게 다크로 고정한다.
      theme: AppTheme.dark(),
      // ponytail: 세션 저장/자동 로그인 없이 로그인 → 메인 진입만 연결. 실제 인증
      // 게이팅(토큰 저장·AuthBloc)은 후속 작업.
      home: Builder(
        builder: (context) => LoginView(
          onDataGsmLogin: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const MainShell()),
          ),
        ),
      ),
    ),
  );
}
