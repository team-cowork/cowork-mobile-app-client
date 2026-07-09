import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'TextArea',
  type: CoworkTextAreaPreview,
  path: '[Design System]/components/text_fields/cowork_text_area',
)
Widget coworkTextAreaPreview(BuildContext context) {
  return const CoworkTextAreaPreview();
}

class CoworkTextAreaPreview extends StatelessWidget {
  const CoworkTextAreaPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cowork/TextArea', style: AppFont.titleL),
            SizedBox(height: 12),
            Text(
              '회의록, 이슈 설명, 긴 메시지 작성에 사용하는 다중 라인 입력입니다.',
              style: AppFont.subtextL,
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                CoworkTextArea(
                  hintText: '논의한 내용을 마크다운으로 정리하세요.',
                  labelText: '회의록',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
