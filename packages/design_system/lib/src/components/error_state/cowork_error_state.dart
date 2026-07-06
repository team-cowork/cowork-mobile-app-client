import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';
import '../button/cowork_button.dart';

/// 오류 상태를 표시하고 재시도 액션을 제공하는 Error State 카드.
///
/// 네트워크 오류, 권한 없음, 실패한 API 응답 등에 사용한다.
/// 타이틀, 설명 문구, 재시도 버튼을 가운데 정렬로 표시한다.
class CoworkErrorState extends StatelessWidget {
  const CoworkErrorState({
    required this.title,
    required this.description,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  /// 굵은 타이틀 문구. (예: 연결에 실패했습니다)
  final String title;

  /// 타이틀 아래에 표시할 설명 문구.
  final String description;

  /// 재시도 버튼 라벨. (예: 다시 시도)
  final String retryLabel;

  /// 재시도 버튼을 눌렀을 때 호출된다.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.r24),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppFont.titleS.copyWith(color: colors.onErrorContainer),
          ),
          const SizedBox(height: AppSpacing.s14),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppFont.subtextL.copyWith(color: colors.onErrorContainer),
          ),
          const SizedBox(height: AppSpacing.s14),
          CoworkButton(
            label: retryLabel,
            onPressed: onRetry,
            size: CoworkButtonSize.medium,
            color: CoworkButtonColor.danger,
          ),
        ],
      ),
    );
  }
}
