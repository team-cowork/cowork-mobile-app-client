import 'package:cowork_app/feature/setting/domain/enums/setting_toggle_enum.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/bloc_scaffold.dart';
import '../../../auth/presentation/blocs/auth/auth_bloc.dart';
import '../../../profile/data/profile_repository.dart';
import '../../data/preference_repository.dart';
import '../../data/push_repository.dart';
import '../blocs/settings/settings_bloc.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

/// 설정 화면. 마이 프로필에서 설정 아이콘을 눌렀을 때 진입한다.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<SettingsBloc, SettingsData>(
      create: (context) => SettingsBloc(
        profile: context.read<ProfileRepository>(),
        preference: context.read<PreferenceRepository>(),
        push: context.read<PushRepository>(),
      )..add(const SettingsRequested()),
      errorTitle: '설정을 불러오지 못했어요',
      onRetry: (context) =>
          context.read<SettingsBloc>().add(const SettingsRequested()),
      appBar: CoworkAppBar.detail(
        title: '설정',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      builder: (context, data) => BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (previous, current) =>
            current is AsyncSuccess<SettingsData> &&
            current.data.saveError != null,
        listener: (context, state) {
          final message = (state as AsyncSuccess<SettingsData>).data.saveError!;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        child: _SettingsBody(data: data),
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.data});

  final SettingsData data;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    final settings = data.settings;

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
          SettingsSection(
            title: '계정',
            children: [
              SettingsTile(
                icon: Icons.person_outline,
                label: '프로필 편집',
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.neutral300,
                ),
                onTap: () => context.push('/profile/edit'),
              ),
              SettingsTile(
                icon: Icons.link,
                label: '연동 계정',
                trailing: SettingsTrailingValue(value: settings.linkedAccount),
                onTap: () {
                  // TODO: 연동 계정 관리 화면으로 이동하는 로직 추가
                },
              ),
            ],
          ),
          SettingsSection(
            title: '알림',
            children: [
              SettingsTile(
                icon: Icons.notifications_outlined,
                label: '푸시 알림',
                trailing: CoworkSwitch(
                  value: settings.pushNotification,
                  enabled: !data.saving,
                  semanticLabel: '푸시 알림',
                  onChanged: (v) => bloc.add(
                    SettingsToggled(SettingsToggle.pushNotification, v),
                  ),
                ),
              ),
              SettingsTile(
                icon: Icons.alternate_email,
                label: '멘션만 받기',
                trailing: CoworkSwitch(
                  value: settings.mentionOnly,
                  // 푸시가 꺼지면(NONE) 멘션 설정을 담을 자리가 없다.
                  enabled: !data.saving && settings.pushNotification,
                  semanticLabel: '멘션만 받기',
                  onChanged: (v) =>
                      bloc.add(SettingsToggled(SettingsToggle.mentionOnly, v)),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: '표시',
            children: [
              const SettingsTile(
                icon: Icons.dark_mode_outlined,
                label: '다크 모드',
                // TODO: 다크 모드 개발 예정. 앱이 다크 테마로 고정돼 있고 화면 대부분이
                // 테마를 따르지 않는 고정 색(AppColors)을 써서, 그때까지 토글을 막는다.
                trailing: CoworkSwitch(
                  value: true,
                  enabled: false,
                  semanticLabel: '다크 모드',
                ),
              ),
              SettingsTile(
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
          SettingsSection(
            title: '기타',
            children: [
              SettingsTile(
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
