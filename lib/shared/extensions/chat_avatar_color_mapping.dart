import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../domain/enums/chat_avatar_color.dart';

extension ChatAvatarColorX on ChatAvatarColor {
  Color toColor() => switch (this) {
    ChatAvatarColor.blue => AppColors.blue500,
    ChatAvatarColor.green => AppColors.green500,
    ChatAvatarColor.amber => AppColors.amber500,
    ChatAvatarColor.red => AppColors.red400,
    ChatAvatarColor.neutral => AppColors.neutral700,
  };
}
