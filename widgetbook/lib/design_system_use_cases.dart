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

@widgetbook.UseCase(
  name: 'Button',
  type: CoworkButtonPreview,
  path: '[Design System]/components',
)
Widget coworkButtonPreview(BuildContext context) {
  return const CoworkButtonPreview();
}

class CoworkButtonPreview extends StatelessWidget {
  const CoworkButtonPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const colors = CoworkButtonColor.values;
    const variants = CoworkButtonVariant.values;
    const sizes = CoworkButtonSize.values;

    return Theme(
      data: AppTheme.light(),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cowork/Button', style: AppFont.titleL),
              const SizedBox(height: 12),
              const Text(
                'Size, Variant, Color, State 축을 가진 기본 CTA/보조 버튼입니다.',
                style: AppFont.subtextL,
              ),
              const SizedBox(height: 16),
              for (final size in sizes) ...[
                for (final variant in variants) ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      for (final color in colors) ...[
                        CoworkButton(
                          label: '버튼',
                          size: size,
                          variant: variant,
                          color: color,
                          onPressed: () {},
                        ),
                        CoworkButton(
                          label: '버튼',
                          size: size,
                          variant: variant,
                          color: color,
                          enabled: false,
                          onPressed: () {},
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'IconButton',
  type: CoworkIconButtonPreview,
  path: '[Design System]/components',
)
Widget coworkIconButtonPreview(BuildContext context) {
  return const CoworkIconButtonPreview();
}

class CoworkIconButtonPreview extends StatelessWidget {
  const CoworkIconButtonPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const colors = CoworkIconButtonColor.values;
    const variants = CoworkIconButtonVariant.values;
    const sizes = CoworkIconButtonSize.values;

    return Theme(
      data: AppTheme.light(),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cowork/Icon Button', style: AppFont.titleL),
              const SizedBox(height: 12),
              const Text(
                '아이콘 단독 액션 버튼입니다. 채널 추가, 파일 첨부, 설정 진입에 사용합니다.',
                style: AppFont.subtextL,
              ),
              const SizedBox(height: 16),
              for (final size in sizes) ...[
                for (final variant in variants) ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      for (final color in colors) ...[
                        CoworkIconButton(
                          icon: AppIcon.settings,
                          size: size,
                          variant: variant,
                          color: color,
                          onPressed: () {},
                        ),
                        CoworkIconButton(
                          icon: AppIcon.settings,
                          size: size,
                          variant: variant,
                          color: color,
                          enabled: false,
                          onPressed: () {},
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'Switch',
  type: CoworkSwitchPreview,
  path: '[Design System]/components',
)
Widget coworkSwitchPreview(BuildContext context) {
  return const CoworkSwitchPreview();
}

class CoworkSwitchPreview extends StatefulWidget {
  const CoworkSwitchPreview({super.key});

  @override
  State<CoworkSwitchPreview> createState() => _CoworkSwitchPreviewState();
}

class _CoworkSwitchPreviewState extends State<CoworkSwitchPreview> {
  bool _onEnabled = true;
  bool _offEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light(),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cowork/Switch', style: AppFont.titleL),
              const SizedBox(height: 12),
              const Text(
                '보안 모드, 공개/비공개, 알림 등 Boolean 설정에 사용합니다.',
                style: AppFont.subtextL,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  CoworkSwitch(
                    value: _onEnabled,
                    onChanged: (next) => setState(() => _onEnabled = next),
                  ),
                  CoworkSwitch(
                    value: _offEnabled,
                    onChanged: (next) => setState(() => _offEnabled = next),
                  ),
                  CoworkSwitch(
                    value: true,
                    enabled: false,
                    onChanged: (_) {},
                  ),
                  CoworkSwitch(
                    value: false,
                    enabled: false,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'SegmentedControl',
  type: CoworkSegmentedControlPreview,
  path: '[Design System]/components',
)
Widget coworkSegmentedControlPreview(BuildContext context) {
  return const CoworkSegmentedControlPreview();
}

class CoworkSegmentedControlPreview extends StatefulWidget {
  const CoworkSegmentedControlPreview({super.key});

  @override
  State<CoworkSegmentedControlPreview> createState() =>
      _CoworkSegmentedControlPreviewState();
}

class _CoworkSegmentedControlPreviewState
    extends State<CoworkSegmentedControlPreview> {
  String _twoSegmentValueM = 'chat';
  String _twoSegmentValueL = 'chat';
  String _threeSegmentValueM = 'chat';
  String _threeSegmentValueL = 'chat';

  static const _twoSegments = [
    CoworkSegment(value: 'chat', label: '채팅'),
    CoworkSegment(value: 'file', label: '파일'),
  ];

  static const _threeSegments = [
    CoworkSegment(value: 'chat', label: '채팅'),
    CoworkSegment(value: 'issue', label: '이슈'),
    CoworkSegment(value: 'meeting', label: '회의록'),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light(),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cowork/Segmented Control', style: AppFont.titleL),
              const SizedBox(height: 12),
              const Text(
                '채팅/파일/계정 공유 같은 탭성 전환에 사용합니다.',
                style: AppFont.subtextL,
              ),
              const SizedBox(height: 24),
              const Text('Count=2', style: AppFont.labelM),
              const SizedBox(height: 12),
              SizedBox(
                width: 320,
                child: CoworkSegmentedControl<String>(
                  segments: _twoSegments,
                  groupValue: _twoSegmentValueM,
                  onChanged: (next) =>
                      setState(() => _twoSegmentValueM = next),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 320,
                child: CoworkSegmentedControl<String>(
                  segments: _twoSegments,
                  groupValue: _twoSegmentValueL,
                  size: CoworkSegmentedControlSize.large,
                  onChanged: (next) =>
                      setState(() => _twoSegmentValueL = next),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 320,
                child: CoworkSegmentedControl<String>(
                  segments: _twoSegments,
                  groupValue: 'chat',
                  enabled: false,
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(height: 32),
              const Text('Count=3', style: AppFont.labelM),
              const SizedBox(height: 12),
              SizedBox(
                width: 480,
                child: CoworkSegmentedControl<String>(
                  segments: _threeSegments,
                  groupValue: _threeSegmentValueM,
                  onChanged: (next) =>
                      setState(() => _threeSegmentValueM = next),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 480,
                child: CoworkSegmentedControl<String>(
                  segments: _threeSegments,
                  groupValue: _threeSegmentValueL,
                  size: CoworkSegmentedControlSize.large,
                  onChanged: (next) =>
                      setState(() => _threeSegmentValueL = next),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 480,
                child: CoworkSegmentedControl<String>(
                  segments: _threeSegments,
                  groupValue: 'chat',
                  enabled: false,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Typography', style: AppFont.headlineM),
              const SizedBox(height: AppSpacing.sm),
              const Text('Headline Large', style: AppFont.headlineL),
              const Text('Body Large', style: AppFont.bodyL),
              const Text('Label Medium', style: AppFont.labelM),
              const SizedBox(height: AppSpacing.lg),
              const Text('Colors', style: AppFont.headlineM),
              const SizedBox(height: AppSpacing.sm),
              const Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _ColorTile(label: 'Primary', color: AppColors.primary),
                  _ColorTile(label: 'Success', color: AppColors.success),
                  _ColorTile(label: 'Warning', color: AppColors.warning),
                  _ColorTile(label: 'Error', color: AppColors.error),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
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
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: const SizedBox.square(dimension: 64),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppFont.labelS),
      ],
    );
  }
}
