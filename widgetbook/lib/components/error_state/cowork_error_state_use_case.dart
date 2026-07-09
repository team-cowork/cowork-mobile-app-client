import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Error State',
  type: CoworkErrorStatePreview,
  path: '[Design System]/components/error_state',
)
Widget coworkErrorStatePreview(BuildContext context) {
  return const CoworkErrorStatePreview();
}

class CoworkErrorStatePreview extends StatelessWidget {
  const CoworkErrorStatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cowork/Error State', style: AppFont.titleL),
            const SizedBox(height: AppSpacing.s12),
            const Text(
              '네트워크 오류, 권한 없음, 실패한 API 응답을 표시합니다.',
              style: AppFont.subtextL,
            ),
            const SizedBox(height: AppSpacing.s24),

            // 네트워크 오류
            CoworkErrorState(
              title: '연결에 실패했습니다',
              description: '네트워크 상태를 확인한 뒤 다시 시도하세요.',
              retryLabel: '다시 시도',
              onRetry: () {},
            ),
            const SizedBox(height: AppSpacing.s16),

            // 실패한 API 응답
            CoworkErrorState(
              title: '데이터를 불러오지 못했습니다',
              description: '잠시 후 다시 시도해 주세요.',
              retryLabel: '새로고침',
              onRetry: () {},
            ),
          ],
        ),
      ),
    );
  }
}
