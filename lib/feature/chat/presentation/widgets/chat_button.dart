import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 홈 화면 상단의 정사각형 채널 리스트 버튼.
class ChatButton extends StatelessWidget {
  const ChatButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSize.componentLarge,
        height: AppSize.componentLarge,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.neutral750,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
