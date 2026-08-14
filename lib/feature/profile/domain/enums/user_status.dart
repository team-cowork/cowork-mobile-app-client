import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 사용자 접속 상태. 아바타 오른쪽 아래 점 색으로 보여준다.
///
/// 서버가 대소문자를 섞어 준다(`ONLINE` 도, `offline` 도 온다). 모르는 값은
/// [offline] 로 본다. 접속 여부를 모를 때 초록으로 켜 두는 것보다 회색이 덜 틀리다.
enum UserStatus {
  online,
  away,
  busy,
  offline;

  static UserStatus from(String? raw) => switch (raw?.toLowerCase()) {
    'online' => online,
    'away' || 'idle' => away,
    'busy' || 'dnd' || 'do_not_disturb' => busy,
    _ => offline,
  };

  /// 상태 점 색상.
  Color get dotColor => switch (this) {
    online => AppColors.green500,
    away => AppColors.amber500,
    busy => AppColors.red500,
    offline => AppColors.neutral400,
  };
}
