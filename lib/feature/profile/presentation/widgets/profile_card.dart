import 'dart:io';

import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/enums/user_status.dart';
import '../../domain/profile.dart';
import '../blocs/profile/profile_bloc.dart';
import '../views/edit_profile_view.dart';

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
                          CoworkBadge(label: badge.label, color: badge.color),
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
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.blue500,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neutral800, width: 4),
                  ),
                  child: ClipOval(child: _avatarImage()),
                ),
                // 45도 방향 원 둘레에 점 중심이 놓이도록 모서리에 붙인다.
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _StatusDot(status: profile.status),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 아바타 이미지. 로컬 사진 > 네트워크 URL > 이니셜 폴백 순으로 표시한다.
  Widget _avatarImage() {
    final fallback = CoworkAvatar(
      initials: profile.name.isEmpty ? '?' : profile.name.characters.first,
    );
    final path = profile.localAvatarPath;
    if (path != null) {
      return Image.file(
        File(path),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    if (profile.avatarUrl.isEmpty) return fallback;
    return Image.network(
      profile.avatarUrl,
      width: 80,
      height: 80,
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
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

/// 아바타 오른쪽 아래 접속 상태 점.
///
/// 디자인은 44px 아바타에 점 13px · 링 2.5px 다. 여기 아바타가 80px 이라 같은
/// 비율(약 0.3)로 키웠다. 링 색은 점이 놓이는 카드 배경과 같아야 파여 보인다.
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final UserStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: status.dotColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.neutral800, width: 4),
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const EditProfileView()),
        );
        // 편집 화면에서 저장한 내용을 프로필에 다시 반영한다.
        if (context.mounted) {
          context.read<ProfileBloc>().add(const ProfileRequested());
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutral700,
          borderRadius: BorderRadius.circular(AppRadius.r10),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s14,
          vertical: 9,
        ),
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
    );
  }
}
