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

class CoworkOptionCardPreview extends StatelessWidget {
  const CoworkOptionCardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cowork/Option Card', style: AppFont.titleL),
            SizedBox(height: AppSpacing.s12),
            Text(
              '선택 가능한 옵션 카드. 채널 유형·템플릿·서비스 선택 등에 사용합니다.',
              style: AppFont.subtextL,
            ),
            SizedBox(height: AppSpacing.s24),
            CoworkOptionCard(
              label: '옵션 제목',
              description: '설명 텍스트',
              selected: true,
            ),
            SizedBox(height: AppSpacing.s12),
            CoworkOptionCard(
              label: '공개 채널',
              description: '누구나 참여할 수 있는 채널',
              icon: Icons.tag,
            ),
            SizedBox(height: AppSpacing.s12),
            CoworkOptionCard(
              label: '비공개 채널',
              description: '초대받은 멤버만 참여할 수 있는 채널',
              icon: Icons.lock_outline,
            ),
          ],
        ),
      ),
    );
  }
}
