import 'package:flutter/material.dart';

import '../color/app_colors.dart';

/// 다크 테마 설정
class DarkTheme {
  DarkTheme._();

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.bgDark,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.bgDark,
      foregroundColor: AppColors.white,
    ),
  );
}
