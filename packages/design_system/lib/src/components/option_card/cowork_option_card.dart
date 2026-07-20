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
    this.trailing,
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

  /// 오른쪽 끝 슬롯. 라디오 표시 등에 사용한다.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final borderRadius = BorderRadius.circular(AppRadius.r10);

    return Material(
      // 선택 시 배경·아이콘까지 브랜드 톤으로 바뀐다. (텍스트 색은 그대로)
      color: selected
          ? Color.alphaBlend(
              colors.primary.withValues(alpha: _selectedTint),
              colors.surfaceContainer,
            )
          : colors.surfaceContainer,
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
                  color: selected
                      ? colors.primary.withValues(alpha: _selectedIconTint)
                      : colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
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
                      // height:null 로 Figma leading-normal(폰트 기본 행간) 적용.
                      style: AppFont.labelXs.copyWith(
                        fontSize: 14,
                        height: null,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // subtextS(12px) 를 스펙(11px)으로 조정.
                      // height:null 로 Figma leading-normal(폰트 기본 행간) 적용.
                      style: AppFont.subtextS.copyWith(
                        fontSize: 11,
                        height: null,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.s12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  static const double _iconSlotSize = 34;

  /// 선택 카드 배경에 얹는 브랜드 틴트 농도.
  static const double _selectedTint = 0.10;

  /// 선택 카드 아이콘 슬롯의 브랜드 틴트 농도.
  static const double _selectedIconTint = 0.18;
}
