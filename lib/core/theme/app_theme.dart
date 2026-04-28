import 'package:flutter/material.dart';

/// 앱 테마 설정
class AppTheme {
  AppTheme._();

  /// 테마 생성
  static ThemeData createTheme({
    required Brightness brightness,
    Color seedColor = Colors.blue,
    bool useMaterial3 = true,
    double borderRadius = 8,
    bool centerTitle = true,
  }) {
    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(centerTitle: centerTitle, elevation: 0),
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
  static ThemeData light({Color? seedColor}) => createTheme(
    brightness: Brightness.light,
    seedColor: seedColor ?? Colors.blue,
  );

  /// 다크 테마
  static ThemeData dark({Color? seedColor}) => createTheme(
    brightness: Brightness.dark,
    seedColor: seedColor ?? Colors.blue,
  );
}
