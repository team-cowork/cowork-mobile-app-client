import 'package:cowork_design_tokens/cowork_design_tokens.dart';
import 'package:flutter/material.dart';

/// Cowork 디자인 시스템 색상 토큰.
///
/// Figma `Cowork Color Foundations`의 Primitive Palette와 Semantic Scheme을
/// Flutter Material 3 [ColorScheme]에 맞춰 노출한다.
///
/// 값은 cowork-design-system 레포의 토큰([CoworkPrimitiveColors],
/// [CoworkLightColors], [CoworkDarkColors])을 그대로 가리킨다.
class AppColors {
  AppColors._();

  // Base
  static const Color black = Color(0xFF000000);
  static const Color white = CoworkPrimitiveColors.white;
  static const Color ink = CoworkPrimitiveColors.ink;
  static const Color darkOnSurface = CoworkPrimitiveColors.fog;

  // Red primitive palette
  static const Color red50 = CoworkPrimitiveColors.red50;
  static const Color red100 = CoworkPrimitiveColors.red100;
  static const Color red200 = CoworkPrimitiveColors.red200;
  static const Color red300 = CoworkPrimitiveColors.red300;
  static const Color red400 = CoworkPrimitiveColors.red400;
  static const Color red500 = CoworkPrimitiveColors.red500;
  static const Color red600 = CoworkPrimitiveColors.red600;
  static const Color red700 = CoworkPrimitiveColors.red700;
  static const Color red800 = CoworkPrimitiveColors.red800;
  static const Color red900 = CoworkPrimitiveColors.red900;

  // Neutral primitive palette
  static const Color neutral50 = CoworkPrimitiveColors.neutral50;
  static const Color neutral100 = CoworkPrimitiveColors.neutral100;
  static const Color neutral200 = CoworkPrimitiveColors.neutral200;
  static const Color neutral300 = CoworkPrimitiveColors.neutral300;
  static const Color neutral400 = CoworkPrimitiveColors.neutral400;
  static const Color neutral500 = CoworkPrimitiveColors.neutral500;
  static const Color neutral600 = CoworkPrimitiveColors.neutral600;
  static const Color neutral650 = CoworkPrimitiveColors.neutral650;
  static const Color neutral700 = CoworkPrimitiveColors.neutral700;
  static const Color neutral750 = CoworkPrimitiveColors.neutral750;
  static const Color neutral800 = CoworkPrimitiveColors.neutral800;
  static const Color neutral850 = CoworkPrimitiveColors.neutral850;
  static const Color neutral900 = CoworkPrimitiveColors.neutral900;

  // Blue primitive palette
  static const Color blue50 = CoworkPrimitiveColors.blue50;
  static const Color blue100 = CoworkPrimitiveColors.blue100;
  static const Color blue300 = CoworkPrimitiveColors.blue300;
  static const Color blue400 = CoworkPrimitiveColors.blue400;
  static const Color blue500 = CoworkPrimitiveColors.blue500;
  static const Color blue600 = CoworkPrimitiveColors.blue600;
  static const Color blue900 = CoworkPrimitiveColors.blue900;

  // Green primitive palette
  static const Color green50 = CoworkPrimitiveColors.green50;
  static const Color green300 = CoworkPrimitiveColors.green300;
  static const Color green400 = CoworkPrimitiveColors.green400;
  static const Color green500 = CoworkPrimitiveColors.green500;
  static const Color green600 = CoworkPrimitiveColors.green600;
  static const Color green900 = CoworkPrimitiveColors.green900;

  // Amber primitive palette
  static const Color amber50 = CoworkPrimitiveColors.amber50;
  static const Color amber300 = CoworkPrimitiveColors.amber300;
  static const Color amber400 = CoworkPrimitiveColors.amber400;
  static const Color amber500 = CoworkPrimitiveColors.amber500;
  static const Color amber600 = CoworkPrimitiveColors.amber600;
  static const Color amber900 = CoworkPrimitiveColors.amber900;

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
        primary: CoworkLightColors.primary,
        onPrimary: CoworkLightColors.onPrimary,
        primaryContainer: CoworkLightColors.primaryContainer,
        onPrimaryContainer: CoworkLightColors.onPrimaryContainer,
        secondary: CoworkLightColors.secondary,
        onSecondary: CoworkLightColors.onSecondary,
        secondaryContainer: CoworkLightColors.secondaryContainer,
        onSecondaryContainer: CoworkLightColors.onSecondaryContainer,
        tertiary: CoworkLightColors.tertiary,
        onTertiary: CoworkLightColors.onTertiary,
        tertiaryContainer: CoworkLightColors.tertiaryContainer,
        onTertiaryContainer: CoworkLightColors.onTertiaryContainer,
        surface: CoworkLightColors.surface,
        onSurface: CoworkLightColors.onSurface,
        surfaceContainerHighest: CoworkLightColors.surfaceVariant,
        onSurfaceVariant: CoworkLightColors.onSurfaceVariant,
        surfaceContainer: CoworkLightColors.surfaceContainer,
        surfaceContainerLow: CoworkLightColors.surfaceContainerLow,
        surfaceContainerHigh: CoworkLightColors.surfaceContainerHigh,
        outline: CoworkLightColors.outline,
        outlineVariant: CoworkLightColors.outlineVariant,
        error: CoworkLightColors.error,
        onError: CoworkLightColors.onError,
        errorContainer: CoworkLightColors.errorContainer,
        onErrorContainer: CoworkLightColors.onErrorContainer,
        inverseSurface: CoworkLightColors.inverseSurface,
        onInverseSurface: CoworkLightColors.inverseOnSurface,
        inversePrimary: CoworkLightColors.inversePrimary,
      );

  /// Figma Dark Mode Semantic Scheme.
  static final ColorScheme darkColorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: CoworkDarkColors.primary,
        onPrimary: CoworkDarkColors.onPrimary,
        primaryContainer: CoworkDarkColors.primaryContainer,
        onPrimaryContainer: CoworkDarkColors.onPrimaryContainer,
        secondary: CoworkDarkColors.secondary,
        onSecondary: CoworkDarkColors.onSecondary,
        secondaryContainer: CoworkDarkColors.secondaryContainer,
        onSecondaryContainer: CoworkDarkColors.onSecondaryContainer,
        tertiary: CoworkDarkColors.tertiary,
        onTertiary: CoworkDarkColors.onTertiary,
        tertiaryContainer: CoworkDarkColors.tertiaryContainer,
        onTertiaryContainer: CoworkDarkColors.onTertiaryContainer,
        surface: CoworkDarkColors.surface,
        onSurface: CoworkDarkColors.onSurface,
        surfaceContainerHighest: CoworkDarkColors.surfaceVariant,
        onSurfaceVariant: CoworkDarkColors.onSurfaceVariant,
        surfaceContainer: CoworkDarkColors.surfaceContainer,
        surfaceContainerLow: CoworkDarkColors.surfaceContainerLow,
        surfaceContainerHigh: CoworkDarkColors.surfaceContainerHigh,
        outline: CoworkDarkColors.outline,
        outlineVariant: CoworkDarkColors.outlineVariant,
        error: CoworkDarkColors.error,
        onError: CoworkDarkColors.onError,
        errorContainer: CoworkDarkColors.errorContainer,
        onErrorContainer: CoworkDarkColors.onErrorContainer,
        inverseSurface: CoworkDarkColors.inverseSurface,
        onInverseSurface: CoworkDarkColors.inverseOnSurface,
        inversePrimary: CoworkDarkColors.inversePrimary,
      );
}
