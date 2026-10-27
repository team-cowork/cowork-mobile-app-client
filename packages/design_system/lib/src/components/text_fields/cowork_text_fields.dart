import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

class CoworkTextField extends StatelessWidget {
  const CoworkTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.fillColor,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;

  /// 지정 시 입력창 배경을 채운다. (예: 검색창처럼 배경이 필요한 경우)
  final Color? fillColor;

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
          obscureText: obscureText,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: obscureText ? 1 : maxLines,
          style: AppFont.subtextL.copyWith(color: colors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            filled: fillColor != null,
            fillColor: fillColor,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r12),
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
