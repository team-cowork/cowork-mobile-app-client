import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/dm_presence.dart';

extension DmPresenceX on DmPresence {
  Color toColor() => switch (this) {
    DmPresence.online => AppColors.green500,
    DmPresence.idle => AppColors.amber500,
    DmPresence.offline => AppColors.neutral300,
  };
}
