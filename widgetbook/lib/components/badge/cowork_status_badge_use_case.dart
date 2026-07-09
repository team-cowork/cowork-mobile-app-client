import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Status Badge',
  type: CoworkStatusBadgePreview,
  path: '[Design System]/components/badge',
)
Widget coworkStatusBadgePreview(BuildContext context) {
  return const CoworkStatusBadgePreview();
}

class CoworkStatusBadgePreview extends StatelessWidget {
  const CoworkStatusBadgePreview({super.key});

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
            Text('Cowork/Status Badge', style: AppFont.titleL),
            SizedBox(height: AppSpacing.s12),
            Text('상태 점(dot)과 라벨. 칸반 컬럼·이슈 상태 표시용입니다.', style: AppFont.subtextL),
            SizedBox(height: AppSpacing.s24),
            Wrap(
              spacing: AppSpacing.s12,
              runSpacing: AppSpacing.s12,
              children: [
                CoworkStatusBadge(label: 'Planned'),
                CoworkStatusBadge(
                  label: 'In Progress',
                  status: CoworkStatusBadgeStatus.inProgress,
                ),
                CoworkStatusBadge(
                  label: 'Done',
                  status: CoworkStatusBadgeStatus.done,
                ),
                CoworkStatusBadge(
                  label: 'Open',
                  status: CoworkStatusBadgeStatus.open,
                ),
                CoworkStatusBadge(
                  label: 'Closed',
                  status: CoworkStatusBadgeStatus.closed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
