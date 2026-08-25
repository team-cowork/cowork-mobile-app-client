import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class AddAssigneeButton extends StatelessWidget {
  const AddAssigneeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.neutral750,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.neutral700,
          style: BorderStyle.solid,
        ),
      ),
      child: AppIcon.plus(size: 16),
    );
  }
}
