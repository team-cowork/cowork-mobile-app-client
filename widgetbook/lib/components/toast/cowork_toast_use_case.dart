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
      // Builder: ScaffoldMessenger 를 찾으려면 Scaffold 하위 context 가 필요하다.
      body: Builder(
        builder: (context) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cowork/Toast', style: AppFont.titleL),
              const SizedBox(height: AppSpacing.s12),
              const Text(
                '업로드 제한, 저장 완료, 오류 알림 등 일시적 피드백입니다.',
                style: AppFont.subtextL,
              ),
              const SizedBox(height: AppSpacing.s24),

              // 버튼을 눌러 애니메이션과 함께 토스트를 띄운다.
              const Text('Trigger', style: AppFont.labelM),
              const SizedBox(height: AppSpacing.s12),
              CoworkButton(
                label: '성공 토스트',
                onPressed: () => CoworkToast.show(
                  context,
                  message: '파일 업로드가 완료되었습니다.',
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              CoworkButton(
                label: '오류 토스트',
                color: CoworkButtonColor.danger,
                onPressed: () => CoworkToast.show(
                  context,
                  message: '업로드에 실패했습니다. 다시 시도해 주세요.',
                  status: CoworkToastStatus.error,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              CoworkButton(
                label: '정보 토스트',
                onPressed: () => CoworkToast.show(
                  context,
                  message: '파일은 최대 20MB까지 업로드할 수 있습니다.',
                  status: CoworkToastStatus.info,
                ),
              ),
              const SizedBox(height: AppSpacing.s32),

              // 정적 미리보기
              const Text('Static', style: AppFont.labelM),
              const SizedBox(height: AppSpacing.s12),
              const CoworkToast(message: '파일 업로드가 완료되었습니다.'),
              const SizedBox(height: AppSpacing.s16),
              const CoworkToast(
                message: '업로드에 실패했습니다. 다시 시도해 주세요.',
                status: CoworkToastStatus.error,
              ),
              const SizedBox(height: AppSpacing.s16),
              const CoworkToast(
                message: '파일은 최대 20MB까지 업로드할 수 있습니다.',
                status: CoworkToastStatus.info,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
