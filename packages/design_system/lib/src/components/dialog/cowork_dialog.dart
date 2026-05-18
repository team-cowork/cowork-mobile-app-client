import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../theme/text_style/app_font.dart';
import '../button/cowork_button.dart';

/// Cowork 디자인 시스템 다이얼로그.
///
/// 삭제 확인, 팀 가입, 닉네임 변경 강제 등 사용자 확인이 필요한 모달에 사용한다.
class CoworkDialog extends StatelessWidget {
  const CoworkDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = '취소',
    this.onCancel,
    this.onConfirm,
    this.confirmColor = CoworkButtonColor.brand,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final CoworkButtonColor confirmColor;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = '취소',
    CoworkButtonColor confirmColor = CoworkButtonColor.brand,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CoworkDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppFont.titleS.copyWith(color: colorScheme.onSurface), 
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              message,
              style: AppFont.subtextL.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CoworkButton(
                  label: cancelLabel,
                  onPressed: onCancel,
                  size: CoworkButtonSize.medium,
                  variant: CoworkButtonVariant.weak,
                  color: CoworkButtonColor.neutral,
                ),
                const SizedBox(width: AppSpacing.s8),
                CoworkButton(
                  label: confirmLabel,
                  onPressed: onConfirm,
                  size: CoworkButtonSize.medium,
                  variant: CoworkButtonVariant.fill,
                  color: confirmColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
