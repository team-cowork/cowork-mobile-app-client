import 'package:flutter/material.dart';

import '../color/app_colors.dart';

/// 라이트 테마 설정
class LightTheme {
  LightTheme._();

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.bgLight,
      foregroundColor: AppColors.grey900,
    ),
  );
}
