import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/avatar_color.dart';
import '../../domain/search_result.dart';

/// 검색 결과의 사람 한 행. 아바타 + 이름 + 역할.
class SearchPersonResultTile extends StatelessWidget {
  const SearchPersonResultTile({super.key, required this.result, this.onTap});

  final SearchPersonResult result;
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
            CoworkAvatar(
              initials: result.initial,
              size: 36,
              backgroundColor: _colorFor(result.avatarColor),
              foregroundColor: AppColors.white,
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
                    result.role,
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

  static Color _colorFor(AvatarColor color) => switch (color) {
    AvatarColor.green => AppColors.green500,
    AvatarColor.amber => AppColors.amber500,
    AvatarColor.blue => AppColors.blue500,
    AvatarColor.red => AppColors.red500,
  };
}
