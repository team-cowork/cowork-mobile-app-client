import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Button',
  type: CoworkButtonPreview,
  path: '[Design System]/components/button',
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
