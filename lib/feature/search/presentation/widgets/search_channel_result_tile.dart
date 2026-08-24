import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/search_result.dart';

/// 검색 결과의 채널 한 행. 해시 아이콘 + 채널명 + 미리보기 텍스트.
class SearchChannelResultTile extends StatelessWidget {
  const SearchChannelResultTile({super.key, required this.result, this.onTap});

  final SearchChannelResult result;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Row(
          spacing: AppSpacing.s12,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.neutral700,
                borderRadius: BorderRadius.circular(AppRadius.r10),
              ),
              child: AppIcon.hashChannel(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    result.name,
                    style: AppFont.labelS.copyWith(
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  Text(
                    result.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.subtextS.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
