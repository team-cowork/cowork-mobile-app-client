import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 디자인 시스템 스키마(시맨틱) 색상 [ThemeExtension].
///
/// 라이트/다크 모드에 따라 시프트되는 Material [ColorScheme] 슬롯만 노출한다.
/// `context.colors.primary` 형태로 접근한다.
///
/// 테마와 무관한 프리미티브 팔레트(`blue50`, `red700` 등)는 [AppColors]를 직접 사용한다.
@immutable
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  const AppColorsTheme({required this.scheme});

  final ColorScheme scheme;

  static final AppColorsTheme light = AppColorsTheme(
    scheme: AppColors.lightColorScheme,
  );
  static final AppColorsTheme dark = AppColorsTheme(
    scheme: AppColors.darkColorScheme,
  );

  Color get primary => scheme.primary;
  Color get onPrimary => scheme.onPrimary;
  Color get primaryContainer => scheme.primaryContainer;
  Color get onPrimaryContainer => scheme.onPrimaryContainer;
  Color get secondary => scheme.secondary;
  Color get onSecondary => scheme.onSecondary;
  Color get secondaryContainer => scheme.secondaryContainer;
  Color get onSecondaryContainer => scheme.onSecondaryContainer;
  Color get tertiary => scheme.tertiary;
  Color get onTertiary => scheme.onTertiary;
  Color get tertiaryContainer => scheme.tertiaryContainer;
  Color get onTertiaryContainer => scheme.onTertiaryContainer;
  Color get surface => scheme.surface;
  Color get onSurface => scheme.onSurface;
  Color get onSurfaceVariant => scheme.onSurfaceVariant;
  Color get surfaceContainer => scheme.surfaceContainer;
  Color get surfaceContainerLow => scheme.surfaceContainerLow;
  Color get surfaceContainerHigh => scheme.surfaceContainerHigh;
  Color get surfaceContainerHighest => scheme.surfaceContainerHighest;
  Color get outline => scheme.outline;
  Color get outlineVariant => scheme.outlineVariant;
  Color get error => scheme.error;
  Color get onError => scheme.onError;
  Color get errorContainer => scheme.errorContainer;
  Color get onErrorContainer => scheme.onErrorContainer;
  Color get inverseSurface => scheme.inverseSurface;
  Color get onInverseSurface => scheme.onInverseSurface;
  Color get inversePrimary => scheme.inversePrimary;

  @override
  AppColorsTheme copyWith({ColorScheme? scheme}) =>
      AppColorsTheme(scheme: scheme ?? this.scheme);

  @override
  AppColorsTheme lerp(ThemeExtension<AppColorsTheme>? other, double t) {
    if (other is! AppColorsTheme) return this;
    return AppColorsTheme(scheme: ColorScheme.lerp(scheme, other.scheme, t));
  }
}

extension AppColorsThemeX on BuildContext {
  /// 디자인 시스템 스키마 색상 접근자. `context.colors.primary`.
  AppColorsTheme get colors =>
      Theme.of(this).extension<AppColorsTheme>() ?? AppColorsTheme.light;
}
