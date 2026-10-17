import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/profile_repository.dart';
import '../../domain/enums/user_status.dart';
import '../../domain/profile.dart';
import '../blocs/profile_status/profile_status_bloc.dart';

/// 상태 설정 바텀시트. 프로필 화면의 아바타를 탭하면 열린다.
///
/// 상태(`custom_status`)와 상태 메시지를 함께 고친다. 서버가 `custom_status` 를
/// 필수로 받으므로, 고른 적 없으면 상태부터 고르게 하고 그 전엔 저장을 막는다.
class ProfileStatusSheet extends StatefulWidget {
  const ProfileStatusSheet({required this.profile, super.key});

  /// 초기 선택값과 메시지를 채울 현재 프로필.
  final Profile profile;

  /// 시트를 띄운다. 저장했으면 true, 그냥 닫으면 null.
  static Future<bool?> show(BuildContext context, Profile profile) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => ProfileStatusBloc(context.read<ProfileRepository>()),
        child: ProfileStatusSheet(profile: profile),
      ),
    );
  }

  /// 고를 수 있는 상태. 서버(preference 서비스)가 허용하는 값만 둔다.
  static const options = [
    (
      status: UserStatus.online,
      value: 'ONLINE',
      label: '온라인',
      description: '대화할 수 있어요',
      icon: Icons.circle_outlined,
    ),
    (
      status: UserStatus.doNotDisturb,
      value: 'DO_NOT_DISTURB',
      label: '방해 금지',
      description: '집중하고 있어요',
      icon: Icons.do_not_disturb_on_outlined,
    ),
  ];

  @override
  State<ProfileStatusSheet> createState() => _ProfileStatusSheetState();
}

class _ProfileStatusSheetState extends State<ProfileStatusSheet> {
  late UserStatus? _selected = widget.profile.customStatus;
  late final _message = TextEditingController(
    text: widget.profile.statusMessage,
  );

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, String value) {
    context.read<ProfileStatusBloc>().add(
      ProfileStatusSubmitted(
        customStatus: value,
        message: _message.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = ProfileStatusSheet.options
        .where((o) => o.status == _selected)
        .firstOrNull;

    return BlocConsumer<ProfileStatusBloc, ProfileStatusState>(
      listenWhen: (_, state) => state.saved,
      listener: (context, _) => Navigator.of(context).pop(true),
      builder: (context, state) => SafeArea(
        child: Padding(
          // 키보드가 올라오면 시트 전체를 밀어 올린다.
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s12,
              AppSpacing.s20,
              AppSpacing.s24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s16,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '상태 설정',
                      style: AppFont.titleS.copyWith(color: colors.onSurface),
                    ),
                    CoworkIconButton(
                      icon: AppIcon.close,
                      size: CoworkIconButtonSize.small,
                      variant: CoworkIconButtonVariant.weak,
                      color: CoworkIconButtonColor.neutral,
                      semanticLabel: '닫기',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Column(
                  spacing: AppSpacing.s8,
                  children: [
                    for (final option in ProfileStatusSheet.options)
                      CoworkOptionCard(
                        label: option.label,
                        description: option.description,
                        icon: option.icon,
                        selected: option.status == _selected,
                        trailing: _Dot(color: option.status.dotColor),
                        onTap: () => setState(() => _selected = option.status),
                      ),
                  ],
                ),
                CoworkTextField(
                  labelText: '상태 메시지',
                  controller: _message,
                  hintText: '예: PR 리뷰 환영 🙌',
                  textInputAction: TextInputAction.done,
                ),
                if (state.error case final error?)
                  Text(
                    error,
                    style: AppFont.subtextS.copyWith(color: colors.error),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: CoworkButton(
                    label: state.saving ? '저장 중…' : '저장',
                    size: CoworkButtonSize.large,
                    // 고른 상태가 있어야 보낼 수 있다. 서버가 필수로 받는다.
                    enabled: selected != null && !state.saving,
                    onPressed: () => _submit(context, selected!.value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 선택지 오른쪽에 붙는 상태 점. 프로필 아바타의 점과 같은 색이다.
class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
