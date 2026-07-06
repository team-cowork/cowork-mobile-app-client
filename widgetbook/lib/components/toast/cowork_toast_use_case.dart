import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Toast',
  type: CoworkToastPreview,
  path: '[Design System]/components/toast',
)
Widget coworkToastPreview(BuildContext context) {
  return const CoworkToastPreview();
}

class CoworkToastPreview extends StatelessWidget {
  const CoworkToastPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cowork/Toast', style: AppFont.titleL),
            SizedBox(height: AppSpacing.s12),
            Text(
              '업로드 제한, 저장 완료, 오류 알림 등 일시적 피드백입니다.',
              style: AppFont.subtextL,
            ),
            SizedBox(height: AppSpacing.s24),

            // 성공
            CoworkToast(message: '파일 업로드가 완료되었습니다.'),
            SizedBox(height: AppSpacing.s16),

            // 오류
            CoworkToast(
              message: '업로드에 실패했습니다. 다시 시도해 주세요.',
              status: CoworkToastStatus.error,
            ),
            SizedBox(height: AppSpacing.s16),

            // 정보
            CoworkToast(
              message: '파일은 최대 20MB까지 업로드할 수 있습니다.',
              status: CoworkToastStatus.info,
            ),
          ],
        ),
      ),
    );
  }
}
