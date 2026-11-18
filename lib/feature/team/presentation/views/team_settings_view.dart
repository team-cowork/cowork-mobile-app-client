import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/utils/initial.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../../shared/widgets/edit_text_sheet.dart';
import '../../../../shared/widgets/settings_header.dart';
import '../../../../shared/widgets/settings_section.dart';
import '../../../../shared/widgets/settings_tile.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../data/repositories/team_repository.dart';
import '../../domain/team_settings.dart';
import '../blocs/team_settings/team_settings_bloc.dart';
import '../widgets/team_action_dialog.dart';

/// 갤러리에서 아이콘으로 쓸 사진 한 장을 골라 파일 경로를 돌려준다. 고르지 않으면 null.
typedef TeamIconPicker = Future<String?> Function();

/// 팀 설정 화면. 홈의 팀 메뉴 `팀 설정` 에서 들어온다.
///
/// 팀 이름·설명·아이콘은 `manage_team`, 팀 삭제는 `delete_team` 권한이 있을 때만
/// 보인다. 팀을 지우면 true 로 닫혀, 홈이 다른 팀으로 옮긴다.
class TeamSettingsView extends StatelessWidget {
  const TeamSettingsView({
    required this.teamId,
    this.pickIcon = _pickFromGallery,
    super.key,
  });

  final int teamId;

  /// 테스트에서 갤러리 대신 정해 둔 파일을 고르게 바꾼다.
  final TeamIconPicker pickIcon;

  static const _chevron = Icon(
    Icons.chevron_right,
    size: 18,
    color: AppColors.neutral300,
  );

  /// 아이콘은 작게 보이므로 512px 로 줄여 올린다. 원본을 그대로 올리면 서버 업로드
  /// 한도(cowork-team `max-file-size-bytes`)를 넘기 쉽다. 한도 검사는 서버가 한다.
  static Future<String?> _pickFromGallery() async =>
      (await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      ))?.path;

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<TeamSettingsBloc, TeamSettingsData>(
      create: (context) => TeamSettingsBloc(
        teamId: teamId,
        teamRepository: context.read<TeamRepository>(),
        profileRepository: context.read<ProfileRepository>(),
      )..add(const TeamSettingsEvent.requested()),
      errorTitle: '팀 설정을 불러오지 못했어요',
      onRetry: (context) => context.read<TeamSettingsBloc>().add(
        const TeamSettingsEvent.requested(),
      ),
      builder: (context, data) {
        final settings = data.settings;

        return BlocListener<TeamSettingsBloc, TeamSettingsState>(
          listenWhen: (previous, current) =>
              current is AsyncSuccess<TeamSettingsData> &&
              current.data.errorMessage != null,
          listener: (context, state) => _showSnackBar(
            context,
            (state as AsyncSuccess<TeamSettingsData>).data.errorMessage!,
          ),
          child: SafeArea(
            child: Column(
              children: [
                SettingsHeader(title: '팀 설정', onBack: () => context.pop()),
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
                        _TeamInfo(settings: settings),
                        if (settings.canManage)
                          _profileSection(context, settings),
                        if (settings.canDelete)
                          SettingsSection(
                            title: '위험 구역',
                            children: [
                              SettingsTile(
                                label: '팀 삭제',
                                destructive: true,
                                onTap: () => _deleteTeam(context, settings),
                              ),
                            ],
                          ),
                        if (!settings.canManage && !settings.canDelete)
                          Text(
                            '팀 정보는 관리 권한이 있는 멤버만 바꿀 수 있어요.',
                            style: AppFont.subtextM.copyWith(
                              color: AppColors.neutral300,
                            ),
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

  Widget _profileSection(BuildContext context, TeamSettings settings) {
    final bloc = context.read<TeamSettingsBloc>();
    return SettingsSection(
      title: '일반',
      children: [
        SettingsTile(
          label: '팀 이름',
          trailing: _chevron,
          onTap: () async {
            final name = await EditTextSheet.show(
              context,
              title: '팀 이름',
              initialText: settings.name,
              allowEmpty: false,
              singleLine: true,
            );
            if (name != null) bloc.add(TeamSettingsEvent.nameChanged(name));
          },
        ),
        SettingsTile(
          label: '팀 설명',
          trailing: _chevron,
          onTap: () async {
            final description = await EditTextSheet.show(
              context,
              title: '팀 설명',
              initialText: settings.description,
              allowEmpty: true,
            );
            if (description != null) {
              bloc.add(TeamSettingsEvent.descriptionChanged(description));
            }
          },
        ),
        SettingsTile(
          label: '팀 아이콘 변경',
          trailing: settings.uploadingIcon
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.neutral300,
                  ),
                )
              : _chevron,
          onTap: settings.uploadingIcon ? null : () => _changeIcon(context),
        ),
        if (settings.iconUrl != null && !settings.uploadingIcon)
          SettingsTile(
            label: '팀 아이콘 삭제',
            onTap: () => bloc.add(const TeamSettingsEvent.iconRemoved()),
          ),
      ],
    );
  }

  Future<void> _changeIcon(BuildContext context) async {
    final bloc = context.read<TeamSettingsBloc>();
    final String? path;
    try {
      path = await pickIcon();
    } catch (e, s) {
      // 권한 거부·손상된 파일 등. 서버와 무관해 Bloc 을 거치지 않고 여기서 알린다.
      Logger.e('팀 아이콘 사진 선택 실패', tag: 'TeamSettings', error: e, stackTrace: s);
      if (context.mounted) {
        _showSnackBar(context, '사진을 불러오지 못했어요. 다시 시도해 주세요.');
      }
      return;
    }
    if (path != null && !bloc.isClosed) {
      bloc.add(TeamSettingsEvent.iconPicked(path));
    }
  }

  /// 팀을 지울지 묻고, 지웠으면 true 로 화면을 닫는다. 홈이 다른 팀으로 옮긴다.
  Future<void> _deleteTeam(BuildContext context, TeamSettings settings) async {
    final repository = context.read<TeamRepository>();
    final deleted = await TeamActionDialog.show(
      context,
      title: '팀을 삭제할까요?',
      message: '"${settings.name}" 팀과 모든 채널·대화·멤버 정보가 삭제되며, 되돌릴 수 없어요.',
      confirmLabel: '삭제',
      runningLabel: '삭제하는 중…',
      failureTitle: '팀을 삭제하지 못했어요.',
      action: () => repository.deleteTeam(teamId),
    );
    if (deleted && context.mounted) context.pop(true);
  }

  static void _showSnackBar(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
}

/// 맨 위의 팀 아이콘·이름·설명.
class _TeamInfo extends StatelessWidget {
  const _TeamInfo({required this.settings});

  final TeamSettings settings;

  static const double _iconSize = 48;

  @override
  Widget build(BuildContext context) {
    final iconUrl = settings.iconUrl;
    final initial = Text(
      initialOf(settings.name),
      style: AppFont.labelM.copyWith(color: AppColors.white),
    );

    return Row(
      spacing: AppSpacing.s12,
      children: [
        Container(
          width: _iconSize,
          height: _iconSize,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.neutral700,
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
          child: iconUrl == null
              ? initial
              : Image.network(
                  iconUrl,
                  width: _iconSize,
                  height: _iconSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => initial,
                ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 3,
            children: [
              Text(
                settings.name,
                style: AppFont.labelM.copyWith(color: AppColors.darkOnSurface),
              ),
              if (settings.description.isNotEmpty)
                Text(
                  settings.description,
                  style: AppFont.subtextM.copyWith(color: AppColors.neutral300),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
