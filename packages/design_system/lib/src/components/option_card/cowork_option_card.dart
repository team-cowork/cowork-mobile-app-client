import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';

/// 선택 가능한 옵션 카드.
///
/// 채널 유형·템플릿·서비스 선택 등에 사용한다. 아이콘 슬롯과 [label],
/// [description]을 가로 한 행으로 노출한다. [selected]가 true 면 브랜드
/// 보더로 강조한다.
class CoworkOptionCard extends StatelessWidget {
  const CoworkOptionCard({
    required this.label,
    required this.description,
    this.icon = Icons.crop_square,
    this.selected = false,
    this.onTap,
    super.key,
  });

  /// 옵션 제목.
  final String label;

  /// 옵션 설명.
  final String description;

  /// 아이콘 슬롯에 표시할 아이콘.
  final IconData icon;

  /// 선택 여부. true 면 브랜드 보더로 강조한다. 기본값은 false.
  final bool selected;

  /// 탭 콜백.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final borderRadius = BorderRadius.circular(AppRadius.r10);

    return Material(
      color: selected ? colors.surfaceContainer : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
        borderRadius: borderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          // ponytail: 세로 10px 은 전용 토큰이 없는 카드 고유값이라 인라인.
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: 10,
          ),
          child: Row(
            children: [
              Ink(
                width: _iconSlotSize,
                height: _iconSlotSize,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Icon(icon, size: 18, color: colors.onSurfaceVariant),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // labelXs(13px) 를 스펙(14px)으로 조정.
                      style: AppFont.labelXs.copyWith(
                        fontSize: 14,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // subtextS(12px) 를 스펙(11px)으로 조정.
                      style: AppFont.subtextS.copyWith(
                        fontSize: 11,
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

  static const double _iconSlotSize = 34;
}
