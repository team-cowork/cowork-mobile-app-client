import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../notes/presentation/views/notes_view.dart';
import '../../../settings/presentation/views/settings_view.dart';
import '../viewModels/profile_bloc.dart';
import '../widgets/github_streak_card.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_meta_chips.dart';

class MyProfileView extends StatelessWidget {
  const MyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(const ProfileRequested()),
      child: Scaffold(
        backgroundColor: AppColors.neutral850,
        appBar: CoworkAppBar.root(
          title: '프로필',
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  AppIcon.settings,
                  color: AppColors.darkOnSurface,
                ),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsView(),
                    ),
                  );
                  // 설정 → 프로필 편집에서 저장한 내용을 반영한다.
                  if (context.mounted) {
                    context.read<ProfileBloc>().add(const ProfileRequested());
                  }
                },
              ),
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileFailure() => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: CoworkErrorState(
                    title: '프로필을 불러오지 못했어요',
                    description: '잠시 후 다시 시도해 주세요.',
                    retryLabel: '다시 시도',
                    onRetry: () => context.read<ProfileBloc>().add(
                      const ProfileRequested(),
                    ),
                  ),
                ),
              ),
              ProfileSuccess(:final profile) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s4,
                  AppSpacing.s16,
                  AppSpacing.s16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.s16,
                  children: [
                    ProfileCard(profile: profile),
                    ProfileMetaChips(labels: profile.metaChips),
                    GithubStreakCard(streak: profile.streak),
                  ],
                ),
              ),
              _ => const Center(child: CoworkLoadingPane()),
            };
          },
        ),
        bottomNavigationBar:
            const _ProfileTabBar(), // TODO: 하단 탭 바를 BottomNavigationBar로 변경하고, 탭 전환 시 라우팅 로직 추가
      ),
    );
  }
}

class _ProfileTabBar extends StatelessWidget {
  const _ProfileTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.neutral800,
        border: Border(top: BorderSide(color: AppColors.neutral700)),
      ),
      padding: const EdgeInsets.only(
        top: AppSpacing.s8,
        bottom: AppSpacing.s20,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const _TabItem(icon: Icons.forum_outlined, label: '채널'),
            const _TabItem(icon: Icons.view_kanban_outlined, label: '이슈'),
            _TabItem(
              icon: Icons.description_outlined,
              label: '회의록',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const NotesView()),
              ),
            ),
            const _TabItem(
              icon: Icons.person_outline,
              label: '프로필',
              selected: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.red400 : AppColors.neutral300;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: AppSpacing.s4),
              Text(
                label,
                style: AppFont.subtextS.copyWith(
                  fontWeight: selected ? AppFont.semiBold : AppFont.regular,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
