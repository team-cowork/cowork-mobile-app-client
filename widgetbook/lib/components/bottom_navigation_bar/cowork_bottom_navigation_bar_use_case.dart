import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'BottomNavigationBar',
  type: CoworkBottomNavigationBarPreview,
  path: '[Design System]/components/bottom_navigation_bar',
)
Widget coworkBottomNavigationBarPreview(BuildContext context) {
  return const CoworkBottomNavigationBarPreview();
}

class CoworkBottomNavigationBarPreview extends StatefulWidget {
  const CoworkBottomNavigationBarPreview({super.key});

  @override
  State<CoworkBottomNavigationBarPreview> createState() =>
      _CoworkBottomNavigationBarPreviewState();
}

class _CoworkBottomNavigationBarPreviewState
    extends State<CoworkBottomNavigationBarPreview> {
  int _index = 0;

  static const _items = [
    CoworkBottomNavigationItem(icon: AppIcon.navChannel, label: '채널'),
    CoworkBottomNavigationItem(icon: AppIcon.navIssue, label: '이슈'),
    CoworkBottomNavigationItem(icon: AppIcon.navNote, label: '회의록'),
    CoworkBottomNavigationItem(icon: AppIcon.navProfile, label: '프로필'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cowork/Bottom Navigation Bar', style: AppFont.titleL),
            const SizedBox(height: 12),
            const Text('루트 탭 화면 전환에 사용합니다.', style: AppFont.subtextL),
            const SizedBox(height: 24),
            const Text('선택 상태 전환', style: AppFont.labelM),
            const SizedBox(height: 12),
            SizedBox(
              width: 390,
              child: CoworkBottomNavigationBar(
                items: _items,
                currentIndex: _index,
                onTap: (next) => setState(() => _index = next),
              ),
            ),
            const SizedBox(height: 32),
            const Text('탭 전환 비활성 (onTap 없음)', style: AppFont.labelM),
            const SizedBox(height: 12),
            SizedBox(
              width: 390,
              child: CoworkBottomNavigationBar(
                items: _items,
                currentIndex: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
