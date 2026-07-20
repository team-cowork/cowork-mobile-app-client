import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class CoworkTextArea extends StatelessWidget {
  const CoworkTextArea({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
    this.minLines = 5,

  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? minLines;



  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppFont.subtextM.copyWith(
              fontWeight: AppFont.semiBold,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: enabled,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          maxLines: null,
          minLines: minLines,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r14),
              borderSide: BorderSide(width: 1, color: colors.outlineVariant),
            ),
            // enabled/focused/error/disabled 테두리는 border 모양에 테마 색을 입혀
            // 자동으로 처리된다.
          ),
        ),
      ],
    );
  }
}
