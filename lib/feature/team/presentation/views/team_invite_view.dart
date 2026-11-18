import 'dart:async';

import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/command_bloc.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../../shared/widgets/create_sheet.dart';
import '../../../search/data/repositories/search_repository.dart';
import '../../../search/domain/enums/avatar_color.dart';
import '../../../search/domain/search_result.dart';
import '../../data/model/responses/invite_response.dart';
import '../../data/repositories/team_repository.dart';
import '../../domain/enums/invite_duration.dart';
import '../blocs/invite_codes/invite_codes_bloc.dart';
import '../blocs/invite_people/invite_people_bloc.dart';

/// 초대 코드를 만드는 요청 하나를 실행하는 [CommandBloc].
typedef _CreateInvite = CommandBloc<InviteDuration, InviteResponse>;

/// 팀 메뉴 `멤버 초대` 화면.
///
/// 웹은 사람 초대 모달에 코드 만들기를 붙이고 코드 목록은 팀 설정에 따로 둔다. 앱은
/// 코드 만들기·목록·무효화와 사람 찾아 초대를 한 화면에 둔다. 셋 다 서버가 같은
/// `manage_invites` 권한으로 막아서, 코드 목록을 못 읽으면(403) 이 화면에서 할 수
/// 있는 게 없다. 그래서 목록 실패를 화면 전체 실패로 보여 준다.
///
/// 코드를 먼저 둔다. 메신저로 코드를 보내는 쪽이 사람을 찾아 넣는 것보다 흔하고, 검색
/// 결과가 길어져도 코드 칸이 밀려나지 않게 하려는 것이다.
class TeamInviteView extends StatelessWidget {
  const TeamInviteView({required this.teamId, super.key});

  final int teamId;

  @override
  Widget build(BuildContext context) {
    final teams = context.read<TeamRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => _CreateInvite(
            (duration) => teams.createInvite(teamId, duration),
            tag: 'Team',
          ),
        ),
        BlocProvider(
          create: (context) => InvitePeopleBloc(
            teams: teams,
            search: context.read<SearchRepository>(),
            teamId: teamId,
          )..add(const InvitePeopleEvent.started()),
        ),
      ],
      child: BlocScaffold<InviteCodesBloc, List<InviteResponse>>(
        create: (_) =>
            InviteCodesBloc(teams, teamId: teamId)
              ..add(const InviteCodesEvent.requested()),
        errorTitle: '멤버를 초대할 수 없어요',
        onRetry: (context) => context.read<InviteCodesBloc>().add(
          const InviteCodesEvent.requested(),
        ),
        appBar: CoworkAppBar.detail(title: '멤버 초대'),
        builder: (context, invites) => _InviteBody(invites: invites),
      ),
    );
  }
}

class _InviteBody extends StatefulWidget {
  const _InviteBody({required this.invites});

  final List<InviteResponse> invites;

  @override
  State<_InviteBody> createState() => _InviteBodyState();
}

class _InviteBodyState extends State<_InviteBody> {
  /// 웹과 같이 7일을 기본으로 둔다.
  InviteDuration _duration = InviteDuration.sevenDays;

  late final StreamSubscription<String> _revokeFailures;

  @override
  void initState() {
    super.initState();
    _revokeFailures = context.read<InviteCodesBloc>().failures.listen(
      (message) => _showSnackBar(message),
    );
  }

  @override
  void dispose() {
    _revokeFailures.cancel();
    super.dispose();
  }

  void _showSnackBar(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _copy(InviteResponse invite) async {
    await Clipboard.setData(ClipboardData(text: invite.inviteCode));
    if (mounted) _showSnackBar('초대 코드를 복사했어요.');
  }

  Future<void> _revoke(InviteResponse invite) async {
    final bloc = context.read<InviteCodesBloc>();
    final confirmed = await CoworkDialog.show(
      context,
      title: '초대 코드를 무효화할까요?',
      message: '${invite.inviteCode} 코드로는 더 이상 팀에 들어올 수 없어요.',
      confirmLabel: '무효화',
      cancelLabel: '취소',
      confirmColor: CoworkButtonColor.danger,
    );
    if ((confirmed ?? false) && !bloc.isClosed) {
      bloc.add(InviteCodesEvent.revokeRequested(invite.inviteCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<_CreateInvite, AsyncState<InviteResponse>>(
          listener: (context, state) {
            if (state case AsyncSuccess(:final data)) {
              context.read<InviteCodesBloc>().add(InviteCodesEvent.added(data));
            }
          },
        ),
        BlocListener<InvitePeopleBloc, InvitePeopleState>(
          listenWhen: (previous, current) =>
              previous.submission != current.submission,
          listener: (context, state) {
            if (state.submission case AsyncSuccess(:final data)) {
              _showSnackBar('$data명을 팀에 초대했어요.');
            }
          },
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s8,
          AppSpacing.s16,
          AppSpacing.s32,
        ),
        children: [
          ..._codeSection(context),
          const SizedBox(height: AppSpacing.s32),
          const _PeopleSection(),
        ],
      ),
    );
  }

  List<Widget> _codeSection(BuildContext context) {
    final colors = context.colors;
    final create = context.watch<_CreateInvite>().state;
    final creating = create is AsyncLoading;

    return [
      const _SectionLabel('초대 코드'),
      const SizedBox(height: AppSpacing.s4),
      Text(
        '코드를 받은 사람은 팀 목록의 + → 초대 코드로 참여에서 들어올 수 있어요.',
        style: AppFont.subtextS.copyWith(color: colors.onSurfaceVariant),
      ),
      const SizedBox(height: AppSpacing.s12),
      CoworkSegmentedControl<InviteDuration>(
        segments: [
          for (final duration in InviteDuration.values)
            CoworkSegment(value: duration, label: _durationLabel(duration)),
        ],
        groupValue: _duration,
        enabled: !creating,
        onChanged: (duration) => setState(() => _duration = duration),
      ),
      const SizedBox(height: AppSpacing.s12),
      SizedBox(
        width: double.infinity,
        child: CoworkButton(
          label: creating ? '만드는 중…' : '코드 만들기',
          enabled: !creating,
          onPressed: () =>
              context.read<_CreateInvite>().add(CommandEvent.run(_duration)),
        ),
      ),
      if (create case AsyncFailure(:final message)) ...[
        const SizedBox(height: AppSpacing.s12),
        CreateSheetError(
          title: '초대 코드를 만들지 못했어요',
          message: message ?? '잠시 후 다시 시도해 주세요.',
        ),
      ],
      const SizedBox(height: AppSpacing.s16),
      if (widget.invites.isEmpty)
        Text(
          '아직 쓸 수 있는 초대 코드가 없어요.',
          style: AppFont.subtextS.copyWith(color: colors.onSurfaceVariant),
        )
      else
        Column(
          spacing: AppSpacing.s8,
          children: [
            for (final invite in widget.invites)
              _InviteCodeTile(
                invite: invite,
                onCopy: () => _copy(invite),
                onRevoke: () => _revoke(invite),
              ),
          ],
        ),
    ];
  }
}

String _durationLabel(InviteDuration duration) => switch (duration) {
  InviteDuration.oneDay => '1일',
  InviteDuration.sevenDays => '7일',
  InviteDuration.thirtyDays => '30일',
  InviteDuration.never => '무제한',
};

/// `11월 24일 12:00까지` 꼴. 기간이 무제한이면 `만료 없음`.
///
/// 만료가 올해가 아니면 `2027년 1월 5일 12:00까지` 처럼 연도를 붙인다. 연말에 만든
/// 30일 코드가 올해인지 내년인지 헷갈리지 않게 하려는 것이다.
String _expiryLabel(InviteResponse invite) {
  final expiresAt = invite.expiresAt;
  if (expiresAt == null) {
    return invite.duration == InviteDuration.never ? '만료 없음' : '만료 시각 모름';
  }
  String two(int value) => value.toString().padLeft(2, '0');
  final year = expiresAt.year == DateTime.now().year
      ? ''
      : '${expiresAt.year}년 ';
  return '$year${expiresAt.month}월 ${expiresAt.day}일 '
      '${two(expiresAt.hour)}:${two(expiresAt.minute)}까지';
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: AppFont.labelS.copyWith(color: context.colors.onSurface),
  );
}

/// 쓸 수 있는 초대 코드 한 줄. 코드·만료 시각과 복사·무효화 버튼.
class _InviteCodeTile extends StatelessWidget {
  const _InviteCodeTile({
    required this.invite,
    required this.onCopy,
    required this.onRevoke,
  });

  final InviteResponse invite;
  final VoidCallback onCopy;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s14,
        AppSpacing.s10,
        AppSpacing.s8,
        AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.r10),
      ),
      child: Row(
        spacing: AppSpacing.s4,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                SelectableText(
                  invite.inviteCode,
                  style: AppFont.labelM.copyWith(color: colors.onSurface),
                ),
                Text(
                  _expiryLabel(invite),
                  style: AppFont.subtextS.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          CoworkIconButton(
            icon: Icons.copy_rounded,
            size: CoworkIconButtonSize.small,
            variant: CoworkIconButtonVariant.weak,
            color: CoworkIconButtonColor.neutral,
            semanticLabel: '초대 코드 복사',
            onPressed: onCopy,
          ),
          CoworkIconButton(
            icon: Icons.link_off_rounded,
            size: CoworkIconButtonSize.small,
            variant: CoworkIconButtonVariant.weak,
            color: CoworkIconButtonColor.neutral,
            semanticLabel: '초대 코드 무효화',
            onPressed: onRevoke,
          ),
        ],
      ),
    );
  }
}

/// 사람을 찾아 골라 바로 초대하는 영역.
class _PeopleSection extends StatelessWidget {
  const _PeopleSection();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bloc = context.read<InvitePeopleBloc>();
    final state = context.watch<InvitePeopleBloc>().state;
    final submitting = state.submission is AsyncLoading;
    final count = state.selected.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('사람 찾아 초대'),
        const SizedBox(height: AppSpacing.s4),
        Text(
          '초대하면 수락 없이 바로 팀 멤버가 돼요.',
          style: AppFont.subtextS.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.s12),
        CoworkTextField(
          hintText: '이름이나 닉네임으로 검색',
          prefixIcon: Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: AppIcon.search(size: 20),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (query) => bloc.add(InvitePeopleEvent.searched(query)),
        ),
        if (count > 0) ...[
          const SizedBox(height: AppSpacing.s12),
          Wrap(
            spacing: AppSpacing.s6,
            runSpacing: AppSpacing.s6,
            children: [
              for (final person in state.selected)
                _SelectedChip(
                  person: person,
                  onRemove: submitting
                      ? null
                      : () => bloc.add(InvitePeopleEvent.toggled(person)),
                ),
            ],
          ),
        ],
        if (state.submission case AsyncFailure(:final message)) ...[
          const SizedBox(height: AppSpacing.s12),
          CreateSheetError(
            title: '초대하지 못했어요',
            message: message ?? '잠시 후 다시 시도해 주세요.',
          ),
        ],
        const SizedBox(height: AppSpacing.s12),
        SizedBox(
          width: double.infinity,
          child: CoworkButton(
            label: submitting
                ? '초대하는 중…'
                : count > 0
                ? '$count명 초대'
                : '초대',
            enabled: count > 0 && !submitting,
            onPressed: () => bloc.add(const InvitePeopleEvent.submitted()),
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        ..._results(context, state),
      ],
    );
  }

  List<Widget> _results(BuildContext context, InvitePeopleState state) {
    final colors = context.colors;
    Widget hint(String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
      child: Text(
        text,
        style: AppFont.subtextS.copyWith(color: colors.onSurfaceVariant),
      ),
    );

    return switch (state.results) {
      AsyncInitial() => [hint('찾은 사람을 눌러 고르면 한 번에 초대할 수 있어요.')],
      AsyncLoading() => const [
        Padding(
          padding: EdgeInsets.all(AppSpacing.s16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      AsyncFailure(:final message) => [
        hint(message ?? '사람을 찾지 못했어요.'),
        CoworkButton(
          label: '다시 찾기',
          variant: CoworkButtonVariant.weak,
          color: CoworkButtonColor.neutral,
          onPressed: () => context.read<InvitePeopleBloc>().add(
            InvitePeopleEvent.searched(state.query),
          ),
        ),
      ],
      AsyncSuccess() when state.candidates.isEmpty => [
        hint("'${state.query}'(으)로 초대할 수 있는 사람이 없어요."),
      ],
      AsyncSuccess() => [
        for (final person in state.candidates)
          _PersonTile(
            person: person,
            onTap: state.submission is AsyncLoading
                ? null
                : () => context.read<InvitePeopleBloc>().add(
                    InvitePeopleEvent.toggled(person),
                  ),
          ),
      ],
    };
  }
}

Color _avatarColorOf(AvatarColor color) => switch (color) {
  AvatarColor.green => AppColors.green500,
  AvatarColor.amber => AppColors.amber500,
  AvatarColor.blue => AppColors.blue500,
  AvatarColor.red => AppColors.red500,
};

/// 검색 결과 한 사람. 누르면 고른 목록에 들어간다.
class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.person, this.onTap});

  final SearchPersonResult person;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s8,
          horizontal: AppSpacing.s4,
        ),
        child: Row(
          spacing: AppSpacing.s12,
          children: [
            CoworkAvatar(
              initials: person.initial,
              size: 36,
              backgroundColor: _avatarColorOf(person.avatarColor),
              foregroundColor: AppColors.white,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    person.name,
                    style: AppFont.labelS.copyWith(color: colors.onSurface),
                  ),
                  if (person.role.isNotEmpty)
                    Text(
                      person.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.subtextS.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.add_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// 고른 사람. 누르면 고른 목록에서 빠진다.
class _SelectedChip extends StatelessWidget {
  const _SelectedChip({required this.person, this.onRemove});

  final SearchPersonResult person;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: '${person.name} 빼기',
      excludeSemantics: true,
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s4,
            AppSpacing.s4,
            AppSpacing.s8,
            AppSpacing.s4,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.r20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.s6,
            children: [
              CoworkAvatar(
                initials: person.initial,
                size: 20,
                backgroundColor: _avatarColorOf(person.avatarColor),
                foregroundColor: AppColors.white,
              ),
              Text(
                person.name,
                style: AppFont.subtextS.copyWith(color: colors.onSurface),
              ),
              Icon(Icons.close, size: 14, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
