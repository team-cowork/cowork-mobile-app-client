import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../feature/chat/presentation/views/chat_view.dart';
import '../../feature/notes/presentation/views/notes_view.dart';
import '../../feature/profile/presentation/views/my_profile_view.dart';
import '../utils/base_scaffold.dart';
import 'coming_soon_view.dart';

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

  int _index = 0;
  final Set<int> _visited = {0};

  Widget _tabView(int index) {
    if (!_visited.contains(index)) return const SizedBox.shrink();
    return switch (index) {
      0 => const ChatView(),
      // TODO: 이슈 화면 퍼블리싱 후 교체 (#49)
      1 => const ComingSoonView(title: '이슈', icon: AppIcon.navIssue),
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
