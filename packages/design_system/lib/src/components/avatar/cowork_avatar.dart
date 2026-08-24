import 'package:flutter/material.dart';

import '../../constants/app_size.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';

/// 팀/사용자 프로필 이미지를 대체하는 기본 아바타.
class CoworkAvatar extends StatelessWidget {
  const CoworkAvatar({
    this.initials = "CW",
    this.size = AppSize.componentMedium,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String initials;
  final double size;

  /// 지정 시 기본 tertiaryContainer 색 대신 사용한다.
  final Color? backgroundColor;

  /// 지정 시 기본 onTertiaryContainer 색 대신 사용한다.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Text(
        initials,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFont.labelM.copyWith(
          color: foregroundColor ?? colors.onTertiaryContainer,
        ),
      ),
    );
  }
}
