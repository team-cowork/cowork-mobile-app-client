import 'package:cowork_design_tokens/cowork_design_tokens.dart';
import 'package:flutter/material.dart';

/// Cowork 디자인 시스템 텍스트 스타일.
///
/// Figma `Cowork Typography`의 Semantic typography 토큰을 Flutter에서
/// 재사용할 수 있도록 노출한다. 값은 cowork-design-system 레포의
/// [CoworkTypography]를 그대로 가리킨다.
class AppFont {
  AppFont._();

  static const String fontFamily = CoworkTypography.fontFamily;
  static const List<String> fontFamilyFallback =
      CoworkTypography.fontFamilyFallback;

  static const double letterSpacing0 = 0;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Display
  static const TextStyle displayS = CoworkTypography.displaySmall;
  static const TextStyle displayM = CoworkTypography.displayMedium;
  static const TextStyle displayL = CoworkTypography.displayLarge;

  // Title
  static const TextStyle titleS = CoworkTypography.titleSmall;
  static const TextStyle titleM = CoworkTypography.titleMedium;
  static const TextStyle titleL = CoworkTypography.titleLarge;

  // Body
  static const TextStyle bodyXs = CoworkTypography.bodyXSmall;
  static const TextStyle bodyM = CoworkTypography.bodyMedium;
  static const TextStyle bodyMStrong = CoworkTypography.bodyMediumStrong;
  static const TextStyle bodyL = CoworkTypography.bodyLarge;

  // Subtext
  static const TextStyle subtextS = CoworkTypography.subtextSmall;
  static const TextStyle subtextM = CoworkTypography.subtextMedium;
  static const TextStyle subtextL = CoworkTypography.subtextLarge;

  // Label
  static const TextStyle labelXs = CoworkTypography.labelXSmall;
  static const TextStyle labelS = CoworkTypography.labelSmall;
  static const TextStyle labelM = CoworkTypography.labelMedium;
  static const TextStyle labelL = CoworkTypography.labelLarge;

  static const TextStyle itemCount = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
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
    headlineLarge: displayS,
    headlineMedium: titleL,
    headlineSmall: titleM,
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
