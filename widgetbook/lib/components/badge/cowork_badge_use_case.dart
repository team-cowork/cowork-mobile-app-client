import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Badge',
  type: CoworkBadgePreview,
  path: '[Design System]/components/badge',
)
Widget coworkBadgePreview(BuildContext context) {
  return const CoworkBadgePreview();
}

class CoworkBadgePreview extends StatelessWidget {
  const CoworkBadgePreview({super.key});

  @override
  Widget build(BuildContext context) {
    // 배지 배경(surfaceContainer)이 scaffold 배경과 같은 회색이라
    // surface(흰색) 위에 올려 칩이 보이도록 한다.
    return const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cowork/Badge', style: AppFont.titleL),
            SizedBox(height: AppSpacing.s12),
            Text(
              '라벨·상태·카운트 표시용 소형 칩입니다. 색상 변형으로 의미를 구분합니다.',
              style: AppFont.subtextL,
            ),
            SizedBox(height: AppSpacing.s24),
            Wrap(
              spacing: AppSpacing.s12,
              runSpacing: AppSpacing.s12,
              children: [
                CoworkBadge(label: 'Neutral'),
                CoworkBadge(label: 'Brand', color: CoworkBadgeColor.brand),
                CoworkBadge(label: 'Green', color: CoworkBadgeColor.green),
                CoworkBadge(label: 'Blue', color: CoworkBadgeColor.blue),
                CoworkBadge(label: 'Amber', color: CoworkBadgeColor.amber),
                CoworkBadge(label: 'Red', color: CoworkBadgeColor.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
