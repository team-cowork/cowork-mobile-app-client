import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';

/// Badge 색상. 라벨 텍스트 색상을 결정한다. 배경은 색상과 무관하게 동일하다.
enum CoworkBadgeColor {
  /// 기본 회색 라벨.
  neutral,

  /// 브랜드(빨강) 강조.
  brand,

  /// 성공/완료 등 긍정 상태.
  green,

  /// 정보 성격의 상태.
  blue,

  /// 경고/주의 상태.
  amber,

  /// 오류/위험 상태.
  red;

  /// 색상에 대응하는 라벨 텍스트 색상.
  ///
  /// neutral·brand·red 는 라이트/다크로 시프트되는 시맨틱 토큰을,
  /// green·blue·amber 는 테마와 무관한 프리미티브 팔레트를 사용한다.
  Color textColor(AppColorsTheme colors) => switch (this) {
    CoworkBadgeColor.neutral => colors.onSurfaceVariant,
    CoworkBadgeColor.brand => colors.primary,
    CoworkBadgeColor.green => AppColors.green500,
    CoworkBadgeColor.blue => AppColors.blue500,
    CoworkBadgeColor.amber => AppColors.amber500,
    CoworkBadgeColor.red => colors.error,
  };
}

/// 라벨·상태·카운트를 표시하는 소형 칩.
///
/// Surface container 배경 위에 색상 라벨을 표시한다. [color] 로 의미를 구분한다.
class CoworkBadge extends StatelessWidget {
  const CoworkBadge({
    required this.label,
    this.color = CoworkBadgeColor.neutral,
    super.key,
  });

  /// 배지에 표시할 라벨 문구.
  final String label;

  /// 라벨 색상. 기본값은 [CoworkBadgeColor.neutral].
  final CoworkBadgeColor color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.r6),
      ),
      // ponytail: 세로 3px 은 전용 토큰이 없는 배지 고유값이라 인라인.
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: 3,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // labelXs(13px) 를 배지 스펙(11px)으로 조정.
        style: AppFont.labelXs.copyWith(
          fontSize: 11,
          color: color.textColor(colors),
        ),
      ),
    );
  }
}
