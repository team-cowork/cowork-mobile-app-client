import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../feature/notes/presentation/views/notes_view.dart';
import '../../feature/profile/presentation/views/my_profile_view.dart';
import '../utils/base_scaffold.dart';

/// 루트 탭 화면(채널·이슈·회의록·프로필)을 담는 공통 셸.
///
/// 하단 탭 바를 화면마다 선언하던 것을 이곳으로 모아 공통화한다. 탭 전환은
/// [IndexedStack]으로 처리해 방문한 탭의 스크롤 위치와 상태를 유지한다.
///
/// [IndexedStack]은 모든 자식을 즉시 빌드하므로, 방문한 적 없는 탭은 자리
/// 표시자로 두어 각 화면의 Bloc(회의록·프로필 API 요청)이 첫 진입 때만 생성되게 한다.
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

  /// 한 번이라도 방문한 탭 인덱스. 방문 전에는 자리 표시자만 빌드한다.
  final Set<int> _visited = {0};

  Widget _tabView(int index) {
    if (!_visited.contains(index)) return const SizedBox.shrink();
    return switch (index) {
      // TODO: 채널 · 이슈 화면 퍼블리싱 후 교체 (#49)
      0 => const _ComingSoonView(title: '채널', icon: AppIcon.navChannel),
      1 => const _ComingSoonView(title: '이슈', icon: AppIcon.navIssue),
      2 => const NotesView(),
      _ => const MyProfileView(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: IndexedStack(
        index: _index,
        children: [for (var i = 0; i < _items.length; i++) _tabView(i)],
      ),
      bottomNavigationBar: CoworkBottomNavigationBar(
        items: _items,
        currentIndex: _index,
        onTap: (next) => setState(() {
          _index = next;
          _visited.add(next);
        }),
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
    return BaseScaffold(
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
