import 'package:cowork_app/feature/settings/domain/enums/setting_toggle_enum.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../../auth/presentation/blocs/auth/auth_bloc.dart';
import '../../../profile/presentation/views/edit_profile_view.dart';
import '../../domain/settings.dart';
import '../blocs/settings/settings_bloc.dart';

/// 설정 화면. 마이 프로필에서 설정 아이콘을 눌렀을 때 진입한다.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<SettingsBloc, Settings>(
      create: (_) => SettingsBloc()..add(const SettingsRequested()),
      errorTitle: '설정을 불러오지 못했어요',
      onRetry: (context) =>
          context.read<SettingsBloc>().add(const SettingsRequested()),
      appBar: CoworkAppBar.detail(
        title: '설정',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      builder: (context, settings) => _SettingsBody(settings: settings),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.settings});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s6,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 22,
        children: [
          _SettingsSection(
            title: '계정',
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                label: '프로필 편집',
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.neutral300,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EditProfileView(),
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.link,
                label: '연동 계정',
                trailing: _SettingsTrailingValue(value: settings.linkedAccount),
                onTap: () {
                  // TODO: 연동 계정 관리 화면으로 이동하는 로직 추가
                },
              ),
            ],
          ),
          _SettingsSection(
            title: '알림',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: '푸시 알림',
                trailing: CoworkSwitch(
                  value: settings.pushNotification,
                  semanticLabel: '푸시 알림',
                  onChanged: (v) => bloc.add(
                    SettingsToggled(SettingsToggle.pushNotification, v),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.alternate_email,
                label: '멘션만 받기',
                trailing: CoworkSwitch(
                  value: settings.mentionOnly,
                  semanticLabel: '멘션만 받기',
                  onChanged: (v) =>
                      bloc.add(SettingsToggled(SettingsToggle.mentionOnly, v)),
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: '표시',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                label: '다크 모드',
                trailing: CoworkSwitch(
                  value: settings.darkMode,
                  semanticLabel: '다크 모드',
                  onChanged: (v) =>
                      bloc.add(SettingsToggled(SettingsToggle.darkMode, v)),
                ),
              ),
              _SettingsTile(
                icon: Icons.commit,
                label: '커밋 스트릭 공개',
                trailing: CoworkSwitch(
                  value: settings.commitStreakPublic,
                  semanticLabel: '커밋 스트릭 공개',
                  onChanged: (v) => bloc.add(
                    SettingsToggled(SettingsToggle.commitStreakPublic, v),
                  ),
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: '기타',
            children: [
              _SettingsTile(
                icon: Icons.logout,
                label: '로그아웃',
                destructive: true,
                onTap: () => context.read<AuthBloc>().add(
                  const AuthEvent.signOutRequested(),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Text(
              'Cowork · 버전 ${settings.version}',
              textAlign: TextAlign.center,
              style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
            ),
          ),
        ],
      ),
    );
  }
}

/// 설정 화면의 한 섹션. 상단 라벨 + 행들을 감싸는 둥근 카드로 구성된다.
///
/// 행 사이에는 1px 구분선을 넣는다.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

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

/// 설정 섹션 카드 안의 한 행.
///
/// 왼쪽 아이콘 + 라벨 + 선택적 [trailing] 위젯으로 구성된다.
/// [onTap]이 있으면 눌리는 행, 없으면 정적인 행이 된다.
/// [destructive]가 true면 로그아웃처럼 빨간색으로 표시한다.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.all(AppSpacing.s14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: destructive ? AppColors.red400 : AppColors.neutral300,
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              label,
              style: AppFont.subtextL.copyWith(
                color: destructive ? AppColors.red400 : AppColors.darkOnSurface,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

/// [_SettingsTile]의 trailing에 쓰는 "값 + 오른쪽 화살표" 조합.
class _SettingsTrailingValue extends StatelessWidget {
  const _SettingsTrailingValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppFont.subtextM.copyWith(color: AppColors.neutral300),
        ),
        const SizedBox(width: AppSpacing.s6),
        const Icon(Icons.chevron_right, size: 18, color: AppColors.neutral300),
      ],
    );
  }
}
