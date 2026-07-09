import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Attachment Card',
  type: CoworkAttachmentCardPreview,
  path: '[Design System]/components/attachment_card',
)
Widget coworkAttachmentCardPreview(BuildContext context) {
  return const CoworkAttachmentCardPreview();
}

class CoworkAttachmentCardPreview extends StatelessWidget {
  const CoworkAttachmentCardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cowork/Attachment Card', style: AppFont.titleL),
            SizedBox(height: AppSpacing.s12),
            Text('업로드된 파일, 이미지, 오디오/비디오 첨부를 표시합니다.', style: AppFont.subtextL),
            SizedBox(height: AppSpacing.s16),
            CoworkAttachmentCard(
              filename: 'sprint-demo.mov',
              subtitle: '42.8MB · 동영상',
            ),
            SizedBox(height: AppSpacing.s12),
            CoworkAttachmentCard(
              filename: 'design-spec.pdf',
              subtitle: '3.2MB · 문서',
              icon: Icons.description_outlined,
            ),
            SizedBox(height: AppSpacing.s12),
            CoworkAttachmentCard(
              filename: 'hero-banner.png',
              subtitle: '1.4MB · 이미지',
              icon: Icons.image_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
