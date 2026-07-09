import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Empty State',
  type: CoworkEmptyStatePreview,
  path: '[Design System]/components/empty_state',
)
Widget coworkEmptyStatePreview(BuildContext context) {
  return const CoworkEmptyStatePreview();
}

class CoworkEmptyStatePreview extends StatelessWidget {
  const CoworkEmptyStatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cowork/Empty State', style: AppFont.titleL),
            SizedBox(height: AppSpacing.s12),
            Text('빈 채널, 검색 결과 없음, 아카이브 없음 상태에 사용합니다.', style: AppFont.subtextL),
            SizedBox(height: AppSpacing.s24),

            // 빈 채널
            CoworkEmptyState(
              icon: Icons.chat_bubble_outline,
              title: '아직 메시지가 없습니다',
              description: '첫 메시지를 보내 팀과 대화를 시작하세요.',
            ),
            SizedBox(height: AppSpacing.s16),

            // 검색 결과 없음
            CoworkEmptyState(
              icon: Icons.search_off,
              title: '검색 결과가 없습니다',
              description: '다른 키워드로 다시 검색해 보세요.',
            ),
            SizedBox(height: AppSpacing.s16),

            // 아카이브 없음
            CoworkEmptyState(
              icon: Icons.inventory_2_outlined,
              title: '보관된 항목이 없습니다',
              description: '보관한 채널이나 메시지가 여기에 표시됩니다.',
            ),
          ],
        ),
      ),
    );
  }
}
