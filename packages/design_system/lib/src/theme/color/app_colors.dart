// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// Cowork 디자인 시스템 색상 토큰.
///
/// Figma `Cowork Color Foundations`의 Primitive Palette와 Semantic Scheme을
/// Flutter Material 3 [ColorScheme]에 맞춰 노출한다.
class AppColors {
  AppColors._();

  // Base
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF060607);

  // Red primitive palette
  static const Color red50 = Color(0xFFFFEEEE);
  static const Color red100 = Color(0xFFFFD4D6);
  static const Color red200 = Color(0xFFFEAFB4);
  static const Color red300 = Color(0xFFFB8890);
  static const Color red400 = Color(0xFFF66570);
  static const Color red500 = Color(0xFFF04452);
  static const Color red600 = Color(0xFFDB2D3D);
  static const Color red700 = Color(0xFFD22030);
  static const Color red800 = Color(0xFFBC1B2A);
  static const Color red900 = Color(0xFFA51926);

  // Neutral primitive palette
  static const Color neutral50 = Color(0xFFF2F3F5);
  static const Color neutral100 = Color(0xFFE3E5E8);
  static const Color neutral200 = Color(0xFFB9BBBE);
  static const Color neutral300 = Color(0xFF949BA4);
  static const Color neutral400 = Color(0xFF6D6F78);
  static const Color neutral500 = Color(0xFF4E5058);
  static const Color neutral600 = Color(0xFF3B3D44);
  static const Color neutral650 = Color(0xFF313338);
  static const Color neutral700 = Color(0xFF2B2D31);
  static const Color neutral750 = Color(0xFF232428);
  static const Color neutral800 = Color(0xFF1E1F22);
  static const Color neutral850 = Color(0xFF141517);
  static const Color neutral900 = Color(0xFF0D0E10);

  // Blue primitive palette
  static const Color blue50 = Color(0xFFEBF0FF);
  static const Color blue100 = Color(0xFFD4E0FF);
  static const Color blue300 = Color(0xFF7FAAFF);
  static const Color blue400 = Color(0xFF4F8EF7);
  static const Color blue500 = Color(0xFF3B6FF0);
  static const Color blue600 = Color(0xFF2F5EC9);
  static const Color blue900 = Color(0xFF0E2B6E);

  // Green primitive palette
  static const Color green50 = Color(0xFFD4F4E2);
  static const Color green300 = Color(0xFF6BD98E);
  static const Color green400 = Color(0xFF3BBF70);
  static const Color green500 = Color(0xFF23A559);
  static const Color green600 = Color(0xFF1B8A47);
  static const Color green900 = Color(0xFF0A3D22);

  // Amber primitive palette
  static const Color amber50 = Color(0xFFFFF3D0);
  static const Color amber300 = Color(0xFFFFCD70);
  static const Color amber400 = Color(0xFFFFBA3B);
  static const Color amber500 = Color(0xFFF0A30A);
  static const Color amber600 = Color(0xFFC98600);
  static const Color amber900 = Color(0xFF4D3300);

  // Legacy semantic aliases
  static const Color primary = red500;
  static const Color primaryDark = red600;
  static const Color secondary = red700;
  static const Color secondaryDark = red800;
  static const Color error = red700;
  static const Color success = green500;
  static const Color warning = amber500;
  static const Color info = blue500;

  // Legacy neutral aliases
  static const Color grey100 = neutral50;
  static const Color grey300 = neutral100;
  static const Color grey500 = neutral300;
  static const Color grey700 = neutral500;
  static const Color grey900 = neutral800;

  // Background aliases
  static const Color bgLight = neutral50;
  static const Color bgDark = neutral850;

  /// Figma Light Mode Semantic Scheme.
  static final ColorScheme lightColorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: red500,
        onPrimary: white,
        primaryContainer: red50,
        onPrimaryContainer: red900,
        secondary: red700,
        onSecondary: white,
        secondaryContainer: red100,
        onSecondaryContainer: red900,
        tertiary: blue500,
        onTertiary: white,
        tertiaryContainer: blue50,
        onTertiaryContainer: blue900,
        background: neutral50,
        onBackground: ink,
        surface: white,
        onSurface: ink,
        surfaceVariant: neutral100,
        onSurfaceVariant: neutral500,
        surfaceContainer: neutral50,
        surfaceContainerLow: white,
        surfaceContainerHigh: neutral100,
        outline: neutral200,
        outlineVariant: neutral100,
        error: red700,
        onError: white,
        errorContainer: red50,
        onErrorContainer: red900,
        inverseSurface: neutral800,
        onInverseSurface: neutral100,
        inversePrimary: red300,
      );

  /// Figma Dark Mode Semantic Scheme.
  static final ColorScheme darkColorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: red400,
        onPrimary: white,
        primaryContainer: red900,
        onPrimaryContainer: red100,
        secondary: red300,
        onSecondary: red900,
        secondaryContainer: red800,
        onSecondaryContainer: red50,
        tertiary: blue300,
        onTertiary: blue900,
        tertiaryContainer: blue900,
        onTertiaryContainer: blue100,
        background: neutral850,
        onBackground: const Color(0xFFDBDEE1),
        surface: neutral800,
        onSurface: const Color(0xFFDBDEE1),
        surfaceVariant: neutral700,
        onSurfaceVariant: neutral300,
        surfaceContainer: neutral750,
        surfaceContainerLow: neutral800,
        surfaceContainerHigh: neutral700,
        outline: neutral600,
        outlineVariant: neutral700,
        error: red400,
        onError: white,
        errorContainer: red900,
        onErrorContainer: red100,
        inverseSurface: neutral100,
        onInverseSurface: neutral800,
        inversePrimary: red600,
      );
}
