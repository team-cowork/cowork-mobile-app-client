import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../shared/extensions/chat_avatar_color_mapping.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../../shared/widgets/settings_section.dart';
import '../../../../shared/widgets/settings_tile.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../setting/data/preference_repository.dart';
import '../../../setting/domain/enums/notification_level.dart';
import '../../data/repositories/channel_repository.dart';
import '../../domain/channel_member.dart';
import '../blocs/channel_settings/channel_settings_bloc.dart';
import '../widgets/channel_settings_header.dart';

class ChannelSettingsView extends StatelessWidget {
  const ChannelSettingsView({required this.channelId, super.key});

  final int channelId;

  static const _chevron = Icon(
    Icons.chevron_right,
    size: 18,
    color: AppColors.neutral300,
  );

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<ChannelSettingsBloc, ChannelSettingsData>(
      create: (context) => ChannelSettingsBloc(
        channelId: channelId,
        channelRepository: context.read<ChannelRepository>(),
        preferenceRepository: context.read<PreferenceRepository>(),
        profileRepository: context.read<ProfileRepository>(),
      )..add(const ChannelSettingsEvent.requested()),
      errorTitle: '채널 설정을 불러오지 못했어요',
      onRetry: (context) => context.read<ChannelSettingsBloc>().add(
        const ChannelSettingsEvent.requested(),
      ),
      builder: (context, data) {
        final bloc = context.read<ChannelSettingsBloc>();
        final settings = data.settings;

        return BlocListener<ChannelSettingsBloc, ChannelSettingsState>(
          listenWhen: (previous, current) =>
              current is AsyncSuccess<ChannelSettingsData> &&
              current.data.errorMessage != null,
          listener: (context, state) {
            final message =
                (state as AsyncSuccess<ChannelSettingsData>).data.errorMessage!;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          },
          child: SafeArea(
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
                              onTap: () async {
                                final name = await _EditTextSheet.show(
                                  context,
                                  title: '채널 이름',
                                  initialText: settings.name,
                                  allowEmpty: false,
                                  singleLine: true,
                                );
                                if (name != null) {
                                  bloc.add(
                                    ChannelSettingsEvent.nameChanged(name),
                                  );
                                }
                              },
                            ),
                            SettingsTile(
                              label: '채널 설명',
                              trailing: _chevron,
                              onTap: () async {
                                final description = await _EditTextSheet.show(
                                  context,
                                  title: '채널 설명',
                                  initialText: settings.description,
                                  allowEmpty: true,
                                );
                                if (description != null) {
                                  bloc.add(
                                    ChannelSettingsEvent.descriptionChanged(
                                      description,
                                    ),
                                  );
                                }
                              },
                            ),
                            SettingsTile(
                              label: '비공개 채널',
                              trailing: CoworkSwitch(
                                value: settings.isPrivate,
                                semanticLabel: '비공개 채널',
                                onChanged: (v) => bloc.add(
                                  ChannelSettingsEvent.privateToggled(v),
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
                                value: _levelLabel(settings.notification.level),
                              ),
                              onTap: () async {
                                final choice =
                                    await _NotificationLevelSheet.show(
                                      context,
                                      selected: settings.notification.level,
                                    );
                                if (choice != null) {
                                  bloc.add(
                                    ChannelSettingsEvent.notificationLevelChanged(
                                      choice.level,
                                    ),
                                  );
                                }
                              },
                            ),
                            SettingsTile(
                              label: '이 채널 음소거',
                              trailing: CoworkSwitch(
                                value: settings.notification.isMuted(
                                  DateTime.now(),
                                ),
                                semanticLabel: '이 채널 음소거',
                                onChanged: (v) => bloc.add(
                                  ChannelSettingsEvent.muteToggled(v),
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
                              onTap: () => context.push(
                                '/chat/channel/$channelId/members',
                              ),
                            ),
                          ],
                        ),
                        const SettingsSection(
                          title: '위험 구역',
                          children: [
                            SettingsTile(label: '채널 삭제', destructive: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _levelLabel(NotificationLevel? level) => switch (level) {
    null => '기본',
    NotificationLevel.all => '모든 메시지',
    NotificationLevel.mentions => '멘션만',
    NotificationLevel.none => '알림 끔',
  };
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

/// 한 줄 텍스트를 고치는 시트. 고친 내용을 돌려주고, 취소하면 null.
class _EditTextSheet extends StatefulWidget {
  const _EditTextSheet({
    required this.title,
    required this.initialText,
    required this.allowEmpty,
    required this.singleLine,
  });

  final String title;
  final String initialText;

  /// 비워서 저장할 수 있는지. 채널 이름은 비울 수 없다.
  final bool allowEmpty;

  /// 한 줄만 받는지. 채널 이름은 줄바꿈이 들어가면 목록·헤더가 두 줄로 보인다.
  final bool singleLine;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String initialText,
    required bool allowEmpty,
    bool singleLine = false,
  }) => showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.neutral800,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _EditTextSheet(
      title: title,
      initialText: initialText,
      allowEmpty: allowEmpty,
      singleLine: singleLine,
    ),
  );

  @override
  State<_EditTextSheet> createState() => _EditTextSheetState();
}

class _EditTextSheetState extends State<_EditTextSheet> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (!widget.allowEmpty && text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s16,
          AppSpacing.s20,
          AppSpacing.s24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s16,
          children: [
            Text(
              widget.title,
              style: AppFont.labelM.copyWith(color: AppColors.darkOnSurface),
            ),
            if (widget.singleLine)
              CoworkTextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              )
            else
              CoworkTextArea(controller: _controller, minLines: 1),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, _) => CoworkButton(
                label: '저장',
                size: CoworkButtonSize.large,
                enabled: widget.allowEmpty || value.text.trim().isNotEmpty,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 알림 수준 시트가 돌려주는 선택. [level] 이 null 이면 `기본` 을 골랐다는 뜻이라, 시트를
/// 그냥 닫은 경우(결과 자체가 null)와 구분한다.
typedef _LevelChoice = ({NotificationLevel? level});

/// 이 채널의 알림 수준을 고르는 시트.
class _NotificationLevelSheet extends StatelessWidget {
  const _NotificationLevelSheet({required this.selected});

  final NotificationLevel? selected;

  static const _options = <(NotificationLevel?, String)>[
    (null, '기본'),
    (NotificationLevel.all, '모든 메시지'),
    (NotificationLevel.mentions, '멘션만'),
    (NotificationLevel.none, '알림 끔'),
  ];

  static Future<_LevelChoice?> show(
    BuildContext context, {
    required NotificationLevel? selected,
  }) => showModalBottomSheet<_LevelChoice>(
    context: context,
    backgroundColor: AppColors.neutral800,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _NotificationLevelSheet(selected: selected),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s16,
          AppSpacing.s20,
          AppSpacing.s24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: Text(
                '알림',
                style: AppFont.labelM.copyWith(color: AppColors.darkOnSurface),
              ),
            ),
            for (final (level, label) in _options)
              InkWell(
                onTap: () => Navigator.of(context).pop((level: level)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: AppFont.subtextL.copyWith(
                            color: AppColors.darkOnSurface,
                          ),
                        ),
                      ),
                      if (level == selected)
                        const Icon(
                          Icons.check,
                          size: 18,
                          color: AppColors.red400,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
