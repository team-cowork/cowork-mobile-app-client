import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Message Composer',
  type: CoworkMessageComposerPreview,
  path: '[Design System]/components/message_composer',
)
Widget coworkMessageComposerPreview(BuildContext context) {
  return const CoworkMessageComposerPreview();
}

class CoworkMessageComposerPreview extends StatefulWidget {
  const CoworkMessageComposerPreview({super.key});

  @override
  State<CoworkMessageComposerPreview> createState() =>
      _CoworkMessageComposerPreviewState();
}

class _CoworkMessageComposerPreviewState
    extends State<CoworkMessageComposerPreview> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cowork/Message Composer', style: AppFont.titleL),
            const SizedBox(height: AppSpacing.s12),
            const Text(
              '파일 업로드와 마크다운 입력을 포함한 메시지 작성 영역입니다.',
              style: AppFont.subtextL,
            ),
            const SizedBox(height: AppSpacing.s16),
            CoworkMessageComposer(
              controller: _controller,
              onAttach: () {},
              onSend: () {},
            ),
          ],
        ),
      ),
    );
  }
}
