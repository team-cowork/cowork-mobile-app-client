import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 검색 화면 상단의 뒤로가기 + 검색창.
class SearchHeader extends StatelessWidget {
  const SearchHeader({
    super.key,
    required this.controller,
    this.onBack,
    this.onClear,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final VoidCallback? onBack;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s4,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      child: Row(
        spacing: AppSpacing.s10,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const SizedBox(
              width: 32,
              height: 44,
              child: Icon(AppIcon.back, size: 20, color: AppColors.darkOnSurface),
            ),
          ),
          Expanded(
            child: CoworkTextField(
              controller: controller,
              onSubmitted: onSubmitted,
              fillColor: AppColors.neutral800,
              prefixIcon: const Icon(
                AppIcon.search,
                size: AppSize.iconSmall,
                color: AppColors.neutral300,
              ),
              suffixIcon: _ClearButton(onPressed: onClear),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.neutral700,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          AppIcon.close,
          size: 12,
          color: AppColors.neutral300,
        ),
      ),
    );
  }
}
