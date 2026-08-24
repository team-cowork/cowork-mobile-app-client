import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/issue_priority.dart';
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
    IssueStatus.done => '완료됨',
  };

  IssueTagColor get tagColor => switch (this) {
    IssueStatus.planned => IssueTagColor.blue,
    IssueStatus.inProgress => IssueTagColor.amber,
    IssueStatus.done => IssueTagColor.green,
  };
}

/// 101~104는 채팅/멤버 화면 mock 유저와 같은 색으로 맞춘다.
Color issueAssigneeColor(int userId) => switch (userId) {
  101 => AppColors.blue500,
  102 => AppColors.green500,
  103 => AppColors.amber500,
  104 => AppColors.red400,
  _ => AppColors.neutral700,
};

extension IssuePriorityX on IssuePriority {
  String get label => switch (this) {
    IssuePriority.high => '높음',
    IssuePriority.medium => '보통',
    IssuePriority.low => '낮음',
  };

  IssueTagColor get tagColor => switch (this) {
    IssuePriority.high => IssueTagColor.red,
    IssuePriority.medium => IssueTagColor.amber,
    IssuePriority.low => IssueTagColor.green,
  };
}
