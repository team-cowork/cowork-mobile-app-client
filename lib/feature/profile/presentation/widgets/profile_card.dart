import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/profile.dart';

/// 프로필 화면 상단의 프로필 카드.
///
/// 커버(그라디언트) + 아바타 + 이름/뱃지/소개 + 프로필 편집 버튼으로 구성된다.
/// Figma `App / Profile` 스펙에 맞춘 다크 전용 레이아웃.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        border: Border.all(color: AppColors.neutral700),
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              Container(
                width: double.infinity,
                height: 96,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.blue500, AppColors.red400],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              // Name / badges / bio / edit
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  52,
                  AppSpacing.s20,
                  AppSpacing.s20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile.name,
                          style: AppFont.titleM.copyWith(
                            color: AppColors.darkOnSurface,
                          ),
                        ),
                        for (final badge in profile.badges) ...[
                          const SizedBox(width: AppSpacing.s8),
                          CoworkBadge(
                            label: badge.label,
                            color: badge.color,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    Text(
                      profile.subtitle,
                      style: AppFont.subtextM.copyWith(
                        color: AppColors.neutral300,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    const _EditProfileButton(),
                  ],
                ),
              ),
            ],
          ),
          // 커버 위에 겹쳐지는 아바타
          Positioned(
            top: 55,
            left: 19,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.blue500,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neutral800, width: 4),
              ),
              child: ClipOval(
                child: Image.network(
                  profile.avatarUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      CoworkAvatar(initials: profile.name.characters.first),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neutral700,
      borderRadius: BorderRadius.circular(AppRadius.r10),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.r10),
        onTap: () {
          // TODO: 프로필 편집 화면으로 이동하는 로직 추가
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 15,
                color: AppColors.darkOnSurface,
              ),
              const SizedBox(width: AppSpacing.s6),
              Text(
                '프로필 편집',
                style: AppFont.subtextM.copyWith(
                  fontWeight: AppFont.semiBold,
                  color: AppColors.darkOnSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
