import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'File Upload Progress',
  type: CoworkFileUploadProgressPreview,
  path: '[Design System]/components/file_upload_progress',
)
Widget coworkFileUploadProgressPreview(BuildContext context) {
  return const CoworkFileUploadProgressPreview();
}

class CoworkFileUploadProgressPreview extends StatelessWidget {
  const CoworkFileUploadProgressPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cowork/File Upload Progress', style: AppFont.titleL),
            SizedBox(height: AppSpacing.s12),
            Text(
              '100MB 제한과 과도한 업로드 제어 상태를 표시합니다.',
              style: AppFont.subtextL,
            ),
            SizedBox(height: AppSpacing.s16),
            CoworkFileUploadProgress(
              filename: 'issue-log.png',
              progress: 0.72,
            ),
            SizedBox(height: AppSpacing.s12),
            CoworkFileUploadProgress(
              filename: 'sprint-demo.mov',
              progress: 0.18,
            ),
            SizedBox(height: AppSpacing.s12),
            CoworkFileUploadProgress(
              filename: 'design-spec-final-v3.pdf',
              progress: 1.0,
              label: '완료',
            ),
          ],
        ),
      ),
    );
  }
}
