import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_size.dart';
import '../../theme/text_style/app_font.dart';

/// 팀/사용자 프로필 이미지를 대체하는 기본 아바타.
class CoworkAvatar extends StatelessWidget {
  const CoworkAvatar({
    this.initials = "CW",
    super.key,
  });

  final String initials;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: AppSize.componentMedium,
      height: AppSize.componentMedium,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.r20),
      ),
      child: Text(
        initials,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFont.labelM.copyWith(color: colorScheme.onTertiaryContainer),
      ),
    );
  }
}
