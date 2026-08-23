import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../../settings/presentation/widgets/settings_section.dart';
import '../../../settings/presentation/widgets/settings_tile.dart';
import '../../domain/channel_member.dart';
import '../../domain/channel_settings.dart';
import '../../domain/enums/channel_settings_toggle.dart';
import '../viewModels/channel_settings_bloc.dart';
import '../widgets/channel_settings_header.dart';
import '../widgets/chat_color_mapping.dart';

class ChannelSettingsView extends StatelessWidget {
  const ChannelSettingsView({super.key});

  static const _chevron = Icon(
    Icons.chevron_right,
    size: 18,
    color: AppColors.neutral300,
  );

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<ChannelSettingsBloc, ChannelSettings>(
      create: (_) =>
          ChannelSettingsBloc()..add(const ChannelSettingsRequested()),
      errorTitle: '채널 설정을 불러오지 못했어요',
      onRetry: (context) =>
          context.read<ChannelSettingsBloc>().add(const ChannelSettingsRequested()),
      builder: (context, settings) {
        final bloc = context.read<ChannelSettingsBloc>();

        return SafeArea(
          child: Column(
            children: [
              ChannelSettingsHeader(onBack: () => context.pop()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16,
                    AppSpacing.s8,
                    AppSpacing.s16,
                    AppSpacing.s16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      _ChannelInfo(
                        name: settings.name,
                        description: settings.description,
                      ),
                      SettingsSection(
                        title: '일반',
                        children: [
                          SettingsTile(
                            label: '채널 이름',
                            trailing: SettingsTrailingValue(
                              value: '# ${settings.name}',
                            ),
                            onTap: () {},
                          ),
                          SettingsTile(
                            label: '채널 설명',
                            trailing: _chevron,
                            onTap: () {},
                          ),
                          SettingsTile(
                            label: '비공개 채널',
                            trailing: CoworkSwitch(
                              value: settings.isPrivate,
                              semanticLabel: '비공개 채널',
                              onChanged: (v) => bloc.add(
                                ChannelSettingsEvent.toggled(
                                  ChannelSettingsToggle.isPrivate,
                                  v,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: '알림',
                        children: [
                          SettingsTile(
                            label: '알림',
                            trailing: SettingsTrailingValue(
                              value: settings.notificationLabel,
                            ),
                            onTap: () {},
                          ),
                          SettingsTile(
                            label: '이 채널 음소거',
                            trailing: CoworkSwitch(
                              value: settings.isMuted,
                              semanticLabel: '이 채널 음소거',
                              onChanged: (v) => bloc.add(
                                ChannelSettingsEvent.toggled(
                                  ChannelSettingsToggle.isMuted,
                                  v,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: '멤버',
                        children: [
                          SettingsTile(
                            label: '멤버 ${settings.memberCount}명',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _MemberAvatarStack(
                                  members: settings.memberPreview,
                                ),
                                const SizedBox(width: AppSpacing.s6),
                                _chevron,
                              ],
                            ),
                            onTap: () => context.push('/chat/channel/members'),
                          ),
                          SettingsTile(
                            label: '멤버 초대',
                            trailing: _chevron,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SettingsSection(
                        title: '위험 구역',
                        children: [
                          SettingsTile(label: '채널 나가기', destructive: true),
                          SettingsTile(label: '채널 삭제', destructive: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChannelInfo extends StatelessWidget {
  const _ChannelInfo({required this.name, required this.description});

  final String name;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.s12,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.neutral700,
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
          child: AppIcon.hash(size: AppSize.iconLarge),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 3,
            children: [
              Text(
                name,
                style: AppFont.labelM.copyWith(color: AppColors.darkOnSurface),
              ),
              Text(
                description,
                style: AppFont.subtextM.copyWith(color: AppColors.neutral300),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MemberAvatarStack extends StatelessWidget {
  const _MemberAvatarStack({required this.members});

  final List<ChannelMember> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox(height: 26);

    return SizedBox(
      height: 26,
      width: 26.0 + (members.length - 1) * 18.0,
      child: Stack(
        children: [
          for (final (index, member) in members.indexed)
            Positioned(
              left: index * 18.0,
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: member.avatarColor.toColor(),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neutral800, width: 2),
                ),
                child: Text(
                  member.profile.avatarInitial,
                  style: AppFont.labelXs.copyWith(
                    fontSize: 11,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
