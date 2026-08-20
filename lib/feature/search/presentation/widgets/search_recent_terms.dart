import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// "최근 검색" 섹션. 최근 검색어를 칩으로 나열한다.
class SearchRecentTerms extends StatelessWidget {
  const SearchRecentTerms({super.key, required this.terms, this.onTapTerm});

  final List<String> terms;
  final ValueChanged<String>? onTapTerm;

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s10,
      children: [
        Text(
          '최근 검색',
          style: AppFont.itemCount.copyWith(color: AppColors.neutral300),
        ),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final term in terms)
              _RecentTermChip(term: term, onTap: () => onTapTerm?.call(term)),
          ],
        ),
      ],
    );
  }
}

class _RecentTermChip extends StatelessWidget {
  const _RecentTermChip({required this.term, this.onTap});

  final String term;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s6,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral750,
          border: Border.all(color: AppColors.neutral700),
          borderRadius: BorderRadius.circular(AppRadius.r14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s6,
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 13,
              color: AppColors.neutral300,
            ),
            Text(
              term,
              style: AppFont.subtextM.copyWith(color: AppColors.darkOnSurface),
            ),
          ],
        ),
      ),
    );
  }
}
