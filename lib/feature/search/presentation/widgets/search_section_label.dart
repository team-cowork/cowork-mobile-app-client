import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// "채널", "사람" 같은 검색 결과 섹션 라벨.
class SearchSectionLabel extends StatelessWidget {
  const SearchSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppFont.itemCount.copyWith(
        color: AppColors.neutral300,
        letterSpacing: 0.4,
      ),
    );
  }
}
