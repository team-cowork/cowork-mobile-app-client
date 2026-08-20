import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../utils/base_scaffold.dart';

class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key, required this.title, required this.icon});

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
