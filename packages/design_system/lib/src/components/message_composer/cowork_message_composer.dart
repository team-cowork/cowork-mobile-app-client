import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_size.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';

/// 메시지 작성 영역.
///
/// 파일 첨부 아이콘, 마크다운 입력 텍스트필드, 전송 버튼으로 구성된다.
/// 동작 로직은 [onAttach]/[onSend]/[onSubmitted] 콜백으로 위임한다.
class CoworkMessageComposer extends StatelessWidget {
  const CoworkMessageComposer({
    this.controller,
    this.hintText = '메시지를 입력하세요. Markdown 지원',
    this.onSubmitted,
    this.onSend,
    this.onAttach,
    super.key,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.r20),
      ),
      child: Row(
        children: [
          InkResponse(
            onTap: onAttach,
            radius: AppSize.iconMedium,
            child: Icon(
              Icons.attach_file_outlined,
              size: AppSize.iconMedium,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              style: AppFont.subtextL.copyWith(color: colors.onSurface),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: AppFont.subtextL.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Material(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.r14),
            child: InkWell(
              onTap: onSend,
              borderRadius: BorderRadius.circular(AppRadius.r14),
              child: SizedBox.square(
                dimension: AppSize.componentMedium,
                child: Icon(
                  Icons.send,
                  size: AppSize.iconSmall,
                  color: colors.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
