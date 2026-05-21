import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Message Item',
  type: CoworkMessageItemPreview,
  path: '[Design System]/components/message_item',
)
Widget coworkMessageItemPreview(BuildContext context) {
  return const CoworkMessageItemPreview();
}

class CoworkMessageItemPreview extends StatelessWidget {
  const CoworkMessageItemPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cowork/Message Item', style: AppFont.titleL),
            SizedBox(height: 12),
            Text(
              '마크다운 채팅 메시지 기본 행입니다.',
              style: AppFont.subtextL,
            ),
            SizedBox(height: 16),
            CoworkMessageItem(
              username: 'junjuny',
              timestamp: '오늘 14:20',
              message:
                  'PR #2 재연결 화면에서 네트워크 상태 감시 로직을 분리했습니다. `Retry` 버튼은 수동 재시도에만 사용합니다.',
            ),
          ],
        ),
      ),
    );
  }
}
