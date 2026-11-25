import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 안 읽은 메시지 수 배지. 빨간 원 안에 숫자를 쓴다.
///
/// DM 목록과 채널 목록이 같은 모양을 쓴다. 0 이하일 때 숨기는 것은 쓰는 쪽이 한다.
class UnreadCountBadge extends StatelessWidget {
  const UnreadCountBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s6,
        vertical: 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.red400,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontFamily: AppFont.fontFamily,
          fontFamilyFallback: AppFont.fontFamilyFallback,
          fontSize: 11,
          fontWeight: AppFont.bold,
          color: AppColors.white,
        ),
      ),
    );
  }
}
