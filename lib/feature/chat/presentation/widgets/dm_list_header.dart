import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class DmListHeader extends StatelessWidget {
  const DmListHeader({this.onSearchTap, this.onEditTap, super.key});

  final VoidCallback? onSearchTap;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s6,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '다이렉트 메시지',
              style: AppFont.titleM.copyWith(color: AppColors.neutral100),
            ),
          ),
          GestureDetector(
            onTap: onSearchTap,
            child: AppIcon.search(size: 22),
          ),
          const SizedBox(width: AppSpacing.s18),
          GestureDetector(onTap: onEditTap, child: AppIcon.edit()),
        ],
      ),
    );
  }
}
