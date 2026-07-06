import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';

/// 데이터를 불러오는 동안 보여주는 Loading Pane 카드.
///
/// 초기 데이터 로딩과 재시도 전 대기 상태에 사용한다.
/// 스피너와 안내 문구를 가운데 정렬로 표시한다.
class CoworkLoadingPane extends StatelessWidget {
  const CoworkLoadingPane({
    this.message = '불러오는 중...',
    this.height = _defaultHeight,
    super.key,
  });

  /// 스피너 아래에 표시할 안내 문구.
  final String message;

  /// 카드 높이. 스피너와 문구가 세로 가운데 정렬된다.
  final double height;

  static const double _defaultHeight = 180;
  static const double _spinnerSize = 44;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.r24),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _spinnerSize,
            height: _spinnerSize,
            child: CircularProgressIndicator(color: colors.primary),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppFont.labelS.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
