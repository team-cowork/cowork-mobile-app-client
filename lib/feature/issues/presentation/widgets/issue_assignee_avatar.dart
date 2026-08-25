import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../profile/domain/profile_entity.dart';

class IssueAssigneeAvatar extends StatelessWidget {
  const IssueAssigneeAvatar({
    required this.profile,
    required this.color,
    required this.selected,
    this.onTap,
    super.key,
  });

  final ProfileEntity profile;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(selected ? 2 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: AppColors.red400, width: 2)
              : null,
        ),
        child: CoworkAvatar(
          initials: profile.avatarInitial,
          size: 32,
          backgroundColor: color,
          foregroundColor: AppColors.white,
        ),
      ),
    );
  }
}
