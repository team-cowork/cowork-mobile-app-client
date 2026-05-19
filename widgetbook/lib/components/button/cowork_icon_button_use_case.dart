import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'IconButton',
  type: CoworkIconButtonPreview,
  path: '[Design System]/components/button',
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
