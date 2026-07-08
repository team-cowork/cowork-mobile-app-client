import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'ChannelListItem',
  type: CoworkChannelListItemPreview,
  path: '[Design System]/components/channel_list_item',
)
Widget coworkChannelListItemPreview(BuildContext context) {
  return const CoworkChannelListItemPreview();
}

class CoworkChannelListItemPreview extends StatelessWidget {
  const CoworkChannelListItemPreview({super.key});

  @override
  Widget build(BuildContext context) {

    return Theme(
      data: AppTheme.light(),
      child: const Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cowork/Channel List Item', style: AppFont.titleL),
              SizedBox(height: 12),
              Text(
                '프로젝트 사이드바의 채널/웹훅/파일/회의록 항목입니다.',
                style: AppFont.subtextL,
              ),
              SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                     CoworkChannelListItem(channelName: '일반채팅', unreadCount: 12)
                    ],
                  ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
