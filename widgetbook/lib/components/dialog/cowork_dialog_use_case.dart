import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Dialog',
  type: CoworkDialogPreview,
  path: '[Design System]/components/dialog',
)
Widget coworkDialogPreview(BuildContext context) {
  return const CoworkDialogPreview();
}

class CoworkDialogPreview extends StatelessWidget {
  const CoworkDialogPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light(),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cowork/Dialog', style: AppFont.titleL),
              const SizedBox(height: 12),
              const Text(
                '삭제 확인, 팀 가입 닉네임 변경 강제 모달 등에 사용합니다.',
                style: AppFont.subtextL,
              ),
              const SizedBox(height: 24),
              const Text('danger', style: AppFont.labelM),
              const SizedBox(height: 12),
              _DialogScrim(
                child: CoworkDialog(
                  title: '채널을 아카이브할까요?',
                  message: '아카이브된 채널은 아카이브 탭에서만 조회할 수 있습니다.',
                  confirmLabel: '아카이브',
                  cancelLabel: '취소',
                  confirmColor: CoworkButtonColor.danger,
                  onCancel: () {},
                  onConfirm: () {},
                ),
              ),
              const SizedBox(height: 24),
              const Text('brand', style: AppFont.labelM),
              const SizedBox(height: 12),
              _DialogScrim(
                child: CoworkDialog(
                  title: '팀에 참가할까요?',
                  message: '수락하면 팀의 모든 채널에 접근할 수 있습니다.',
                  confirmLabel: '참가',
                  cancelLabel: '취소',
                  onCancel: () {},
                  onConfirm: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogScrim extends StatelessWidget {
  const _DialogScrim({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r14),
      child: SizedBox(
        height: 280,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(size: const Size(400, 280)),
          child: ColoredBox(
            color: Colors.black26,
            child: child,
          ),
        ),
      ),
    );
  }
}
