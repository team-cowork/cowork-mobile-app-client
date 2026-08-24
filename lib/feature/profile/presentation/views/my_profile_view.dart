import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../../settings/presentation/views/settings_view.dart';
import '../../data/github_repository.dart';
import '../../data/profile_repository.dart';
import '../../domain/profile.dart';
import '../blocs/profile/profile_bloc.dart';
import '../widgets/github_streak_card.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_meta_chips.dart';

class MyProfileView extends StatelessWidget {
  const MyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<ProfileBloc, Profile>(
      create: (context) => ProfileBloc(
        context.read<ProfileRepository>(),
        context.read<GithubRepository>(),
      )..add(const ProfileRequested()),
      errorTitle: '프로필을 불러오지 못했어요',
      onRetry: (context) =>
          context.read<ProfileBloc>().add(const ProfileRequested()),
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
                  MaterialPageRoute<void>(builder: (_) => const SettingsView()),
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
      builder: (context, profile) => SingleChildScrollView(
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
    );
  }
}
