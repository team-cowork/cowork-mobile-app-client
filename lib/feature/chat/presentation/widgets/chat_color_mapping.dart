import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/chat_avatar_color.dart';
import '../../domain/enums/dm_presence.dart';

extension ChatAvatarColorX on ChatAvatarColor {
  Color toColor() => switch (this) {
    ChatAvatarColor.blue => AppColors.blue500,
    ChatAvatarColor.green => AppColors.green500,
    ChatAvatarColor.amber => AppColors.amber500,
    ChatAvatarColor.red => AppColors.red400,
    ChatAvatarColor.neutral => AppColors.neutral700,
  };
}

extension DmPresenceX on DmPresence {
  Color toColor() => switch (this) {
    DmPresence.online => AppColors.green500,
    DmPresence.idle => AppColors.amber500,
    DmPresence.offline => AppColors.neutral300,
  };
}
