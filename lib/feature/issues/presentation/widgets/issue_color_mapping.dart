import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/issue_status.dart';
import '../../domain/enums/issue_tag_color.dart';

extension IssueTagColorX on IssueTagColor {
  // Figma 배지 배경은 팔레트 프리미티브가 아니라 전용 톤이라 인라인.
  Color get background => switch (this) {
    IssueTagColor.blue => const Color(0xFF1F2A52),
    IssueTagColor.amber => const Color(0xFF3D2A12),
    IssueTagColor.red => AppColors.red900,
    IssueTagColor.green => AppColors.green900,
  };

  Color get foreground => switch (this) {
    IssueTagColor.blue => AppColors.blue300,
    IssueTagColor.amber => AppColors.amber400,
    IssueTagColor.red => AppColors.red300,
    IssueTagColor.green => AppColors.green300,
  };
}

extension IssueStatusX on IssueStatus {
  String get label => switch (this) {
    IssueStatus.planned => '계획됨',
    IssueStatus.inProgress => '진행중',
  };

  IssueTagColor get tagColor => switch (this) {
    IssueStatus.planned => IssueTagColor.blue,
    IssueStatus.inProgress => IssueTagColor.amber,
  };
}

/// GitHub 사용자명으로 아바타 색을 고른다. 같은 사람이 늘 같은 색이 되게 한다.
Color issueAuthorColor(String author) {
  const colors = [
    AppColors.blue500,
    AppColors.green500,
    AppColors.amber500,
    AppColors.red400,
  ];
  return colors[author.codeUnits.fold(0, (sum, unit) => sum + unit) %
      colors.length];
}
