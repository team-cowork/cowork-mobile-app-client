import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';

/// 파일 업로드 진행 상태를 표시하는 카드.
///
/// 파일명과 진행률(%)을 한 행으로 노출하고, 하단에 진행률 바를 그린다.
/// 100MB 제한과 과도한 업로드 제어 상태를 표시하는 데 사용한다.
class CoworkFileUploadProgress extends StatelessWidget {
  const CoworkFileUploadProgress({
    required this.filename,
    required this.progress,
    this.label,
    super.key,
  });

  /// 업로드 중인 파일명.
  final String filename;

  /// 진행률. 0.0 ~ 1.0 범위로 클램프된다.
  final double progress;

  /// 진행률 우측에 표시할 라벨. 미지정 시 `progress`를 백분율로 표시한다.
  final String? label;

  static const double _barHeight = AppSpacing.s8;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final value = progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0;
    final percentLabel = label ?? '${(value * 100).round()}%';

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFont.labelS.copyWith(color: colors.onSurface),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                percentLabel,
                style: AppFont.subtextM.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: _barHeight,
              backgroundColor: colors.outlineVariant,
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
