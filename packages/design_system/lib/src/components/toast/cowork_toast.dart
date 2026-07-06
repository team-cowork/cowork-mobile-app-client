import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_size.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';

/// Toast 상태. 상태 아이콘과 색상을 결정한다.
enum CoworkToastStatus {
  /// 저장 완료 등 성공 피드백. (초록 체크)
  success(Icons.check_circle_rounded, AppColors.green500),

  /// 오류 알림 등 실패 피드백. (빨강)
  error(Icons.error_rounded, AppColors.red500),

  /// 업로드 제한 안내 등 일반 정보. (파랑)
  info(Icons.info_rounded, AppColors.blue500);

  const CoworkToastStatus(this.icon, this.iconColor);

  final IconData icon;
  final Color iconColor;
}

/// 일시적 피드백을 표시하는 Toast pill.
///
/// 업로드 제한, 저장 완료, 오류 알림 등 짧은 안내에 사용한다.
/// Inverse surface 배경 위에 상태 아이콘과 메시지를 가로로 표시한다.
class CoworkToast extends StatelessWidget {
  const CoworkToast({
    required this.message,
    this.status = CoworkToastStatus.success,
    super.key,
  });

  /// 토스트에 표시할 메시지 문구.
  final String message;

  /// 토스트 상태. 아이콘과 색상을 결정한다. 기본값은 [CoworkToastStatus.success].
  final CoworkToastStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: const BoxConstraints(minHeight: _minHeight),
      decoration: BoxDecoration(
        color: colors.inverseSurface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s14,
      ),
      child: Row(
        children: [
          Icon(status.icon, size: AppSize.iconSmall, color: status.iconColor),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              message,
              style: AppFont.labelS.copyWith(color: colors.onInverseSurface),
            ),
          ),
        ],
      ),
    );
  }

  static const double _minHeight = 64;
}
