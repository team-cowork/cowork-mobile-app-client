import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';

/// Status Badge 상태. 앞의 점(dot) 색상을 결정한다.
enum CoworkStatusBadgeStatus {
  /// 예정.
  planned,

  /// 진행 중.
  inProgress,

  /// 완료.
  done,

  /// 열림.
  open,

  /// 닫힘.
  closed;

  /// 상태에 대응하는 점 색상.
  ///
  /// planned·closed 는 라이트/다크로 시프트되는 시맨틱 토큰을,
  /// inProgress·done·open 은 테마와 무관한 프리미티브 팔레트를 사용한다.
  Color dotColor(AppColorsTheme colors) => switch (this) {
    CoworkStatusBadgeStatus.planned => colors.onSurfaceVariant,
    CoworkStatusBadgeStatus.closed => colors.onSurfaceVariant,
    CoworkStatusBadgeStatus.inProgress => AppColors.blue500,
    CoworkStatusBadgeStatus.done => AppColors.green500,
    CoworkStatusBadgeStatus.open => AppColors.green500,
  };
}

/// 상태 점(dot)과 라벨을 표시하는 pill.
///
/// 칸반 컬럼·이슈 상태 표시에 사용한다. Surface container 배경 위에
/// [status] 색상의 점과 라벨을 가로로 표시한다.
class CoworkStatusBadge extends StatelessWidget {
  const CoworkStatusBadge({
    required this.label,
    this.status = CoworkStatusBadgeStatus.planned,
    super.key,
  });

  /// 배지에 표시할 라벨 문구.
  final String label;

  /// 상태. 점 색상을 결정한다. 기본값은 [CoworkStatusBadgeStatus.planned].
  final CoworkStatusBadgeStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: ShapeDecoration(
        color: colors.surfaceContainer,
        shape: const StadiumBorder(),
      ),
      // ponytail: 좌8/우11/세로5 는 배지 고유값이라 인라인.
      padding: const EdgeInsets.only(
        left: AppSpacing.s8,
        right: 11,
        top: 5,
        bottom: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(
              color: status.dotColor(colors),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.s6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // labelXs(13px) 를 배지 스펙(11px)으로 조정.
            style: AppFont.labelXs.copyWith(
              fontSize: 11,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  static const double _dotSize = 8;
}
