import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 사용자 접속 상태. 아바타 오른쪽 아래 점 색으로 보여준다.
///
/// 서버는 접속 상태(`status`: `online` / `offline`)와 사용자가 고른 상태
/// (`custom_status`: 예 `DO_NOT_DISTURB`)를 따로 준다. 모르는 값은 [offline] 로
/// 본다. 접속 여부를 모를 때 초록으로 켜 두는 것보다 회색이 덜 틀리다.
enum UserStatus {
  online,
  doNotDisturb,
  offline;

  static UserStatus from(String? raw) => switch (raw?.toUpperCase()) {
    'ONLINE' => online,
    'DO_NOT_DISTURB' => doNotDisturb,
    _ => offline,
  };

  /// 점에 보일 상태. 사용자가 고른 상태가 있으면 그걸, 고른 적 없으면(null)
  /// 서버가 정하는 접속 상태를 따른다.
  static UserStatus of({String? presence, String? custom}) =>
      custom == null || custom.isEmpty ? from(presence) : from(custom);

  /// 상태 점 색상.
  Color get dotColor => switch (this) {
    online => AppColors.green500,
    doNotDisturb => AppColors.red500,
    offline => AppColors.neutral400,
  };
}
