import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../feature/notes/presentation/views/notes_view.dart';
import '../../feature/profile/presentation/views/my_profile_view.dart';

/// 루트 탭 화면(채널·이슈·회의록·프로필)을 담는 공통 셸.
///
/// 하단 탭 바를 화면마다 선언하던 것을 이곳으로 모아 공통화한다. 탭 전환은
/// [IndexedStack]으로 처리해 각 탭의 스크롤 위치와 상태를 유지한다.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _items = [
    CoworkBottomNavigationItem(icon: AppIcon.navChannel, label: '채널'),
    CoworkBottomNavigationItem(icon: AppIcon.navIssue, label: '이슈'),
    CoworkBottomNavigationItem(icon: AppIcon.navNote, label: '회의록'),
    CoworkBottomNavigationItem(icon: AppIcon.navProfile, label: '프로필'),
  ];

  /// 첫 탭(채널)에서 시작한다.
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral850,
      body: IndexedStack(
        index: _index,
        children: const [
          // TODO: 채널 · 이슈 화면 퍼블리싱 후 교체 (#49)
          _ComingSoonView(title: '채널', icon: AppIcon.navChannel),
          _ComingSoonView(title: '이슈', icon: AppIcon.navIssue),
          NotesView(),
          MyProfileView(),
        ],
      ),
      bottomNavigationBar: CoworkBottomNavigationBar(
        items: _items,
        currentIndex: _index,
        onTap: (next) => setState(() => _index = next),
      ),
    );
  }
}

/// 아직 퍼블리싱되지 않은 탭의 자리 표시 화면.
class _ComingSoonView extends StatelessWidget {
  const _ComingSoonView({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral850,
      appBar: CoworkAppBar.root(title: title),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: CoworkEmptyState(
            icon: icon,
            title: '$title 화면을 준비 중이에요',
            description: '곧 만나보실 수 있어요.',
          ),
        ),
      ),
    );
  }
}
