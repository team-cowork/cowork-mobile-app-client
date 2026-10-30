import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 여러 값 중 하나를 고르는 칩. 회의록 채널·섹션 입력 형식을 고를 때 쓴다.
///
/// Figma `새 채널` 시트의 프로젝트 칩 스타일. 고른 칩은 파란 보더로 강조한다.
class NoteChoiceChip extends StatelessWidget {
  const NoteChoiceChip({
    required this.label,
    required this.selected,
    this.onTap,
    super.key,
  });

  final String label;
  final bool selected;

  /// null 이면 눌리지 않는다. 불러오는 중처럼 고를 수 없을 때 넘기지 않는다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.r8);

    return Material(
      color: selected
          ? AppColors.blue500.withValues(alpha: 0.18)
          : AppColors.neutral750,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? AppColors.blue500 : AppColors.neutral700,
        ),
        borderRadius: radius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: 7,
          ),
          child: Text(
            label,
            style: AppFont.subtextM.copyWith(
              height: null,
              fontWeight: AppFont.semiBold,
              color: selected ? AppColors.blue300 : AppColors.neutral300,
            ),
          ),
        ),
      ),
    );
  }
}
