import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';

/// 콘텐츠가 비어 있을 때 보여주는 Empty State 카드.
///
/// 빈 채널, 검색 결과 없음, 아카이브 없음 등 아무 상태가 없을 때 사용한다.
/// 틴트된 아이콘과 타이틀, 설명 문구를 가운데 정렬로 표시한다.
class CoworkEmptyState extends StatelessWidget {
  const CoworkEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  /// 상황을 나타내는 아이콘. (예: 채팅, 검색, 아카이브)
  final IconData icon;

  /// 굵은 타이틀 문구.
  final String title;

  /// 타이틀 아래에 표시할 설명 문구.
  final String description;

  static const double _iconBoxSize = 64;
  static const double _iconGlyphSize = 32;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.r24),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _iconBoxSize,
            height: _iconBoxSize,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.r20),
            ),
            child: Icon(
              icon,
              size: _iconGlyphSize,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.s14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppFont.titleS.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: AppSpacing.s14),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppFont.subtextL.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
