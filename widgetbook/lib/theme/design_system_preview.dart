import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Light',
  type: DesignSystemPreview,
  path: '[Design System]/theme',
)
Widget lightThemePreview(BuildContext context) {
  return const DesignSystemPreview(themeMode: ThemeMode.light);
}

@widgetbook.UseCase(
  name: 'Dark',
  type: DesignSystemPreview,
  path: '[Design System]/theme',
)
Widget darkThemePreview(BuildContext context) {
  return const DesignSystemPreview(themeMode: ThemeMode.dark);
}

class DesignSystemPreview extends StatelessWidget {
  const DesignSystemPreview({required this.themeMode, super.key});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == ThemeMode.dark;
    final theme = isDark ? AppTheme.dark() : AppTheme.light();

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Cowork Design System')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Typography', style: AppFont.headlineM),
              const SizedBox(height: AppSpacing.s8),
              const Text('Headline Large', style: AppFont.headlineL),
              const Text('Body Large', style: AppFont.bodyL),
              const Text('Label Medium', style: AppFont.labelM),
              const SizedBox(height: AppSpacing.s24),
              const Text('Colors', style: AppFont.headlineM),
              const SizedBox(height: AppSpacing.s8),
              const Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: [
                  _ColorTile(label: 'Primary', color: AppColors.primary),
                  _ColorTile(label: 'Success', color: AppColors.success),
                  _ColorTile(label: 'Warning', color: AppColors.warning),
                  _ColorTile(label: 'Error', color: AppColors.error),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(AppIcon.home),
                label: const Text('Primary Action'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          child: const SizedBox.square(dimension: 64),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(label, style: AppFont.labelS),
      ],
    );
  }
}
