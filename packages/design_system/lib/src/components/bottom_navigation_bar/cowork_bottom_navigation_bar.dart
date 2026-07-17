import 'package:flutter/material.dart';

import '../../constants/app_size.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/text_style/app_font.dart';

/// 하단 네비게이션 바의 탭 항목.
class CoworkBottomNavigationItem {
  const CoworkBottomNavigationItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Cowork 하단 네비게이션 바.
///
/// Figma `cowork mobile app` 페이지의 루트 탭 바(채널·이슈·회의록·프로필)를
/// 공통 위젯으로 정리한 것이다. 선택된 탭은 강조색으로 표시한다.
///
/// [Scaffold.bottomNavigationBar] 슬롯에 그대로 넣을 수 있으며, 하단 인셋은
/// 내부 [SafeArea]가 소비한다.
class CoworkBottomNavigationBar extends StatelessWidget {
  const CoworkBottomNavigationBar({
    required this.items,
    required this.currentIndex,
    this.onTap,
    super.key,
  }) : assert(items.length >= 2, 'items must contain at least 2 items');

  final List<CoworkBottomNavigationItem> items;

  /// 선택된 탭의 인덱스.
  final int currentIndex;

  /// 선택되지 않은 탭을 눌렀을 때 호출된다. null이면 탭 전환이 비활성화된다.
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.neutral800,
        border: Border(top: BorderSide(color: AppColors.neutral700)),
      ),
      padding: const EdgeInsets.only(
        top: AppSpacing.s8,
        bottom: AppSpacing.s20,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              _TabItem(
                item: items[i],
                selected: i == currentIndex,
                onTap: onTap == null || i == currentIndex
                    ? null
                    : () => onTap!(i),
              ),
          ],
        ),
      ),
    );
  }
}

/// 하단 네비게이션 바의 개별 탭.
class _TabItem extends StatelessWidget {
  const _TabItem({required this.item, required this.selected, this.onTap});

  final CoworkBottomNavigationItem item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.red400 : AppColors.neutral300;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: AppSize.iconLarge, color: color),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.subtextS.copyWith(
                    fontWeight: selected ? AppFont.semiBold : AppFont.regular,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
