import 'package:flutter/material.dart';

import 'color/app_colors.dart';
import 'color/app_colors_theme.dart';
import 'text_style/app_font.dart';

/// 앱 테마 설정
class AppTheme {
  AppTheme._();

  /// 테마 생성
  static ThemeData createTheme({
    required Brightness brightness,
    Color? seedColor,
    bool useMaterial3 = true,
    double borderRadius = 8,
    bool centerTitle = true,
  }) {
    final colorScheme = seedColor == null
        ? switch (brightness) {
            Brightness.light => AppColors.lightColorScheme,
            Brightness.dark => AppColors.darkColorScheme,
          }
        : ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);

    return ThemeData(
      useMaterial3: useMaterial3,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: [
        brightness == Brightness.light
            ? AppColorsTheme.light
            : AppColorsTheme.dark,
      ],
      textTheme: AppFont.textTheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? AppColors.bgLight
          : AppColors.bgDark,
      appBarTheme: AppBarTheme(
        centerTitle: centerTitle,
        elevation: 0,
        backgroundColor: brightness == Brightness.light
            ? AppColors.bgLight
            : AppColors.bgDark,
        foregroundColor: colorScheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// 라이트 테마
  static ThemeData light({Color? seedColor}) =>
      createTheme(brightness: Brightness.light, seedColor: seedColor);

  /// 다크 테마
  static ThemeData dark({Color? seedColor}) =>
      createTheme(brightness: Brightness.dark, seedColor: seedColor);
}
