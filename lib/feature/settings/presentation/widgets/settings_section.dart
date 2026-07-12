import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 설정 화면의 한 섹션. 상단 라벨 + 행들을 감싸는 둥근 카드로 구성된다.
///
/// 행 사이에는 1px 구분선을 넣는다.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFont.subtextS.copyWith(
            fontWeight: AppFont.semiBold,
            color: AppColors.neutral300,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.neutral800,
            border: Border.all(color: AppColors.neutral700),
            borderRadius: BorderRadius.circular(AppRadius.r14),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.neutral700,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
