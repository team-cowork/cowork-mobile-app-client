import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 채널 목록의 그룹(카테고리) 헤더. 펼침/접힘 화살표와 그룹명을 표시한다.
class ChannelGroupHeader extends StatelessWidget {
  const ChannelGroupHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s12,
        0,
        AppSpacing.s4,
      ),
      child: Row(
        children: [
          AppIcon.dropDown(size: 12),
          const SizedBox(width: AppSpacing.s4),
          Text(
            label,
            style: AppFont.itemCount.copyWith(color: AppColors.neutral300),
          ),
        ],
      ),
    );
  }
}
