import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Option Card',
  type: CoworkOptionCardPreview,
  path: '[Design System]/components/option_card',
)
Widget coworkOptionCardPreview(BuildContext context) {
  return const CoworkOptionCardPreview();
}

class CoworkOptionCardPreview extends StatefulWidget {
  const CoworkOptionCardPreview({super.key});

  @override
  State<CoworkOptionCardPreview> createState() =>
      _CoworkOptionCardPreviewState();
}

class _CoworkOptionCardPreviewState extends State<CoworkOptionCardPreview> {
  static const _options = [
    (label: '공개 채널', description: '누구나 참여할 수 있는 채널', icon: Icons.tag),
    (label: '비공개 채널', description: '초대받은 멤버만 참여할 수 있는 채널', icon: Icons.lock_outline),
    (label: '다이렉트 메시지', description: '1:1 비공개 대화', icon: Icons.alternate_email),
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cowork/Option Card', style: AppFont.titleL),
            const SizedBox(height: AppSpacing.s12),
            const Text(
              '선택 가능한 옵션 카드. 채널 유형·템플릿·서비스 선택 등에 사용합니다.',
              style: AppFont.subtextL,
            ),
            const SizedBox(height: AppSpacing.s24),
            for (var i = 0; i < _options.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.s12),
              CoworkOptionCard(
                label: _options[i].label,
                description: _options[i].description,
                icon: _options[i].icon,
                selected: _selected == i,
                onTap: () => setState(() => _selected = i),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
