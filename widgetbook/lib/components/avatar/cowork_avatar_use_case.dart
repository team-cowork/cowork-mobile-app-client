import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Avatar',
  type: CoworkAvatarPreview,
  path: '[Design System]/components/avatar',
)
Widget coworkAvatarPreview(BuildContext context) {
  return const CoworkAvatarPreview();
}

class CoworkAvatarPreview extends StatelessWidget {
  const CoworkAvatarPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cowork/Avatar', style: AppFont.titleL),
            SizedBox(height: 12),
            Text(
              '팀/사용자 프로필 이미지를 대체하는 기본 아바타입니다.',
              style: AppFont.subtextL,
            ),
            SizedBox(height: 16),
            CoworkAvatar(initials: 'CW'),
          ],
        ),
      ),
    );
  }
}
