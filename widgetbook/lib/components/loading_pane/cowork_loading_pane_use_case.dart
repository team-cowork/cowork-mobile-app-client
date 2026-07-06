import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Loading Pane',
  type: CoworkLoadingPanePreview,
  path: '[Design System]/components/loading_pane',
)
Widget coworkLoadingPanePreview(BuildContext context) {
  return const CoworkLoadingPanePreview();
}

class CoworkLoadingPanePreview extends StatelessWidget {
  const CoworkLoadingPanePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cowork/Loading Pane', style: AppFont.titleL),
            SizedBox(height: AppSpacing.s12),
            Text(
              '초기 데이터 로딩과 재시도 전 대기 상태에 사용합니다.',
              style: AppFont.subtextL,
            ),
            SizedBox(height: AppSpacing.s24),

            // 기본 로딩
            CoworkLoadingPane(message: '불러오는 중...'),
            SizedBox(height: AppSpacing.s16),

            // 재시도 대기
            CoworkLoadingPane(message: '다시 시도하는 중...'),
            SizedBox(height: AppSpacing.s16),

            // 스피너만 표시
            CoworkLoadingPane(),
          ],
        ),
      ),
    );
  }
}
