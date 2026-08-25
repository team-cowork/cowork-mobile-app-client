import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class IssueMetaRow extends StatelessWidget {
  const IssueMetaRow({required this.label, this.value, this.trailing, super.key});

  final String label;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppFont.subtextM.copyWith(color: AppColors.neutral300),
            ),
          ),
          if (trailing != null)
            trailing!
          else if (value != null)
            Text(
              value!,
              style: AppFont.labelXs.copyWith(color: AppColors.darkOnSurface),
            ),
        ],
      ),
    );
  }
}
