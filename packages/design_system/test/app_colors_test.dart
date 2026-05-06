import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors primitive palette', () {
    test('matches Cowork Figma primitive colors', () {
      expect(AppColors.red500, const Color(0xFFF04452));
      expect(AppColors.neutral850, const Color(0xFF141517));
      expect(AppColors.blue500, const Color(0xFF3B6FF0));
      expect(AppColors.green500, const Color(0xFF23A559));
      expect(AppColors.amber500, const Color(0xFFF0A30A));
    });
  });

  group('AppColors semantic schemes', () {
    test('matches Figma light semantic colors', () {
      final scheme = AppColors.lightColorScheme;

      expect(scheme.primary, AppColors.red500);
      expect(scheme.onPrimary, AppColors.white);
      expect(scheme.primaryContainer, AppColors.red50);
      expect(scheme.onPrimaryContainer, AppColors.red900);
      expect(scheme.surface, AppColors.white);
      expect(scheme.onSurface, AppColors.ink);
      expect(scheme.surfaceContainerHighest, AppColors.neutral100);
      expect(scheme.inversePrimary, AppColors.red300);
    });

    test('matches Figma dark semantic colors', () {
      final scheme = AppColors.darkColorScheme;

      expect(scheme.primary, AppColors.red400);
      expect(scheme.onPrimary, AppColors.white);
      expect(scheme.primaryContainer, AppColors.red900);
      expect(scheme.onPrimaryContainer, AppColors.red100);
      expect(scheme.surface, AppColors.neutral800);
      expect(scheme.onSurface, AppColors.darkOnSurface);
      expect(scheme.surfaceContainerHighest, AppColors.neutral700);
      expect(scheme.inversePrimary, AppColors.red600);
    });
  });

  group('AppFont semantic styles', () {
    test('matches Figma typography tokens', () {
      expect(AppFont.displayS.fontSize, 26);
      expect(AppFont.displayS.height, 35 / 26);
      expect(AppFont.displayS.fontWeight, FontWeight.w700);
      expect(AppFont.bodyM.fontSize, 17);
      expect(AppFont.bodyM.height, 26 / 17);
      expect(AppFont.bodyM.fontWeight, FontWeight.w400);
      expect(AppFont.bodyMStrong.fontWeight, FontWeight.w500);
      expect(AppFont.labelM.fontSize, 17);
      expect(AppFont.labelM.height, 21 / 17);
      expect(AppFont.labelM.fontWeight, FontWeight.w600);
    });
  });

  group('AppTheme', () {
    test('uses Cowork light color scheme by default', () {
      final theme = AppTheme.light();

      expect(theme.colorScheme.primary, AppColors.lightColorScheme.primary);
      expect(theme.textTheme.displaySmall?.fontSize, AppFont.displayS.fontSize);
      expect(
        theme.textTheme.displaySmall?.fontWeight,
        AppFont.displayS.fontWeight,
      );
      expect(theme.scaffoldBackgroundColor, AppColors.bgLight);
    });

    test('uses Cowork dark color scheme by default', () {
      final theme = AppTheme.dark();

      expect(theme.colorScheme.primary, AppColors.darkColorScheme.primary);
      expect(theme.textTheme.displaySmall?.fontSize, AppFont.displayS.fontSize);
      expect(
        theme.textTheme.displaySmall?.fontWeight,
        AppFont.displayS.fontWeight,
      );
      expect(theme.scaffoldBackgroundColor, AppColors.bgDark);
    });
  });
}
