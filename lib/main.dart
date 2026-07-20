import 'package:cowork_app/core/presentation/main_shell.dart';
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
      home: const MainShell(),
    ),
  );
}
