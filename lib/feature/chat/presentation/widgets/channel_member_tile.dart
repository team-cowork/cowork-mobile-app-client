import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/channel_member.dart';
import 'chat_color_mapping.dart';

class ChannelMemberTile extends StatelessWidget {
  const ChannelMemberTile({required this.member, this.onMoreTap, super.key});

  final ChannelMember member;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final avatar = CoworkAvatar(
      initials: member.profile.avatarInitial,
      backgroundColor: member.avatarColor.toColor(),
      foregroundColor: AppColors.white,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSize.componentMedium,
            height: AppSize.componentMedium,
            child: Stack(
              children: [
                Opacity(opacity: member.isOnline ? 1 : 0.55, child: avatar),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: member.isOnline
                          ? AppColors.green500
                          : AppColors.neutral300,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neutral850,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.s6,
                  children: [
                    Text(
                      member.profile.name,
                      style: AppFont.subtextL.copyWith(
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    if (member.isOwner) const _OwnerBadge(),
                  ],
                ),
                Text(
                  member.role,
                  style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
                ),
              ],
            ),
          ),
          GestureDetector(onTap: onMoreTap, child: AppIcon.more(size: 20)),
        ],
      ),
    );
  }
}

/// 채널 소유자 표시. 팔레트에 없는 보라색은 이 배지 전용값이라 인라인.
class _OwnerBadge extends StatelessWidget {
  const _OwnerBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2050),
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: const Text(
        'OWNER',
        style: TextStyle(
          fontFamily: AppFont.fontFamily,
          fontFamilyFallback: AppFont.fontFamilyFallback,
          fontSize: 10,
          fontWeight: AppFont.bold,
          color: Color(0xFFD4A3FF),
        ),
      ),
    );
  }
}
