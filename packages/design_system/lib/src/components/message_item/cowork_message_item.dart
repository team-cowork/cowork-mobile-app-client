import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';
import '../avatar/cowork_avatar.dart';

/// 마크다운 채팅 메시지 기본 행.
///
/// 아바타 + 사용자명 + 시간 + 마크다운 본문으로 구성된다.
/// [avatar]가 주어지면 그대로 사용하고, 미주입 시 [initials]로 [CoworkAvatar]를 렌더링한다.
class CoworkMessageItem extends StatelessWidget {
  const CoworkMessageItem({
    required this.username,
    required this.timestamp,
    required this.message,
    this.initials = "CW",
    this.avatar,
    super.key,
  });

  final String username;
  final String timestamp;
  final String message;
  final String initials;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar ?? CoworkAvatar(initials: initials),
        const SizedBox(width: AppSpacing.s20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$username · $timestamp',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.labelXs.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              MarkdownBody(
                data: message,
                shrinkWrap: true,
                styleSheet: MarkdownStyleSheet(
                  p: AppFont.subtextL.copyWith(color: colors.onSurface),
                  code: AppFont.subtextL.copyWith(
                    color: colors.onSurface,
                    fontFamily: 'monospace',
                    backgroundColor: colors.surfaceContainerHigh,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
