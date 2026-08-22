import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/icon/app_icon.dart';
import '../../theme/text_style/app_font.dart';

class CoworkMessageComposer extends StatelessWidget {
  const CoworkMessageComposer({
    this.controller,
    this.hintText = '메시지를 입력하세요. Markdown 지원',
    this.minLines = 1,
    this.maxLines = 5,
    this.onSubmitted,
    this.onSend,
    this.onAttach,
    this.showAttachButton = true,
    super.key,
  });

  final TextEditingController? controller;
  final String hintText;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;

  /// false면 첨부 버튼을 그리지 않는다. (예: 스레드 답글처럼 첨부가 없는 입력창)
  final bool showAttachButton;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      // Figma 스펙: 좌14/우8/상하8. 좌우가 비대칭이라 인라인.
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.r24),
      ),
      child: Row(
        children: [
          if (showAttachButton) ...[
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onAttach,
                customBorder: const CircleBorder(),
                // Figma 전송 버튼(40)보다 작은 보조 액션이라 인라인.
                child: SizedBox.square(
                  dimension: 32,
                  child: Center(child: AppIcon.attach()),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s10),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              minLines: minLines,
              maxLines: maxLines,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
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
          const SizedBox(width: AppSpacing.s10),
          Material(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.r14),
            child: InkWell(
              onTap: onSend,
              borderRadius: BorderRadius.circular(AppRadius.r14),
              // Figma 스펙: 40x40.
              child: SizedBox.square(
                dimension: 40,
                child: Center(child: AppIcon.send()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
