import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_size.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';

/// 업로드된 파일·이미지·오디오/비디오 첨부를 표시하는 카드.
///
/// 파일 아이콘과 [filename], [subtitle]을 가로 한 행으로 노출한다.
/// 아이콘은 [icon] 슬롯으로 교체 가능하다.
class CoworkAttachmentCard extends StatelessWidget {
  const CoworkAttachmentCard({
    required this.filename,
    required this.subtitle,
    this.icon = Icons.insert_drive_file_outlined,
    this.onTap,
    super.key,
  });

  final String filename;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s14),
          child: Row(
            children: [
              Container(
                width: AppSize.iconContainer,
                height: AppSize.iconContainer,
                decoration: BoxDecoration(
                  color: colors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Icon(
                  icon,
                  size: AppSize.iconLarge,
                  color: colors.onTertiaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filename,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.labelS.copyWith(color: colors.onSurface),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.subtextM.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
