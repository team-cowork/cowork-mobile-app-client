import 'package:flutter/material.dart';

/// Cowork 디자인 시스템 텍스트 스타일.
///
/// Figma `Cowork Typography`의 Semantic typography 토큰을 Flutter에서
/// 재사용할 수 있도록 노출한다.
class AppFont {
  AppFont._();

  static const String fontFamily = 'Inter';
  static const List<String> fontFamilyFallback = ['Noto Sans KR'];

  static const double letterSpacing0 = 0;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Display
  static const TextStyle displayS = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 26,
    height: 35 / 26,
    fontWeight: bold,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle displayM = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 28,
    height: 38 / 28,
    fontWeight: bold,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle displayL = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 30,
    height: 41 / 30,
    fontWeight: bold,
    letterSpacing: letterSpacing0,
  );

  // Title
  static const TextStyle titleS = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 20,
    height: 27 / 20,
    fontWeight: bold,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle titleM = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 22,
    height: 30 / 22,
    fontWeight: bold,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle titleL = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: bold,
    letterSpacing: letterSpacing0,
  );

  // Body
  static const TextStyle bodyXs = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    height: 20 / 13,
    fontWeight: regular,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle bodyM = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 17,
    height: 26 / 17,
    fontWeight: regular,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle bodyMStrong = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 17,
    height: 26 / 17,
    fontWeight: medium,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle bodyL = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 19,
    height: 29 / 19,
    fontWeight: regular,
    letterSpacing: letterSpacing0,
  );

  // Subtext
  static const TextStyle subtextS = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: regular,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle subtextM = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: regular,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle subtextL = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: regular,
    letterSpacing: letterSpacing0,
  );

  // Label
  static const TextStyle labelXs = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    height: 16 / 13,
    fontWeight: semiBold,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle labelS = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 19 / 15,
    fontWeight: semiBold,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle labelM = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 17,
    height: 21 / 17,
    fontWeight: semiBold,
    letterSpacing: letterSpacing0,
  );

  static const TextStyle labelL = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 19,
    height: 24 / 19,
    fontWeight: semiBold,
    letterSpacing: letterSpacing0,
  );

  // Legacy aliases
  static const TextStyle headlineL = displayL;
  static const TextStyle headlineM = displayM;
  static const TextStyle headlineS = titleL;
  static const TextStyle bodyS = bodyXs;

  /// Cowork semantic styles mapped to Flutter Material text roles.
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayL,
    displayMedium: displayM,
    displaySmall: displayS,
    headlineLarge: titleL,
    headlineMedium: titleM,
    headlineSmall: titleS,
    titleLarge: titleL,
    titleMedium: titleM,
    titleSmall: titleS,
    bodyLarge: bodyL,
    bodyMedium: bodyM,
    bodySmall: bodyXs,
    labelLarge: labelL,
    labelMedium: labelM,
    labelSmall: labelS,
  );
}
