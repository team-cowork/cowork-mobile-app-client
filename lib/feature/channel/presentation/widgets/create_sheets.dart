import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/command_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/create_sheet.dart';
import '../../../project/data/model/requests/create_project_request.dart';
import '../../../project/data/model/responses/project_summary_response.dart';
import '../../../project/data/repositories/project_repository.dart';
import '../../data/model/requests/create_channel_request.dart';
import '../../data/repositories/channel_repository.dart';
import '../../domain/channel.dart';
import '../../domain/enums/channel_type.dart';

/// 채널 시트가 돌려주는 결과.
///
/// [projectFailed] 는 채널은 만들었지만 고른 프로젝트에 넣지 못했다는 뜻이다. 채널이
/// 이미 있으므로 시트를 실패로 두지 않고 닫은 뒤 홈이 따로 알린다.
typedef NewChannelResult = ({Channel channel, bool projectFailed});

/// 채널 생성 요청 하나를 실행하는 [CommandBloc].
typedef _CreateChannel = CommandBloc<CreateChannelRequest, NewChannelResult>;

/// 프로젝트 생성 요청 하나를 실행하는 [CommandBloc].
typedef _CreateProject =
    CommandBloc<CreateProjectRequest, ProjectSummaryResponse>;

/// 선택 여부를 보더로 표시하는 카드 컨테이너.
///
/// [CoworkOptionCard] 는 `아이콘 + 제목 + 설명` 한 행이 고정이라, 공개 범위처럼
/// 내용 구성이 다른 카드에 쓴다. 배경·보더 규칙은 [CoworkOptionCard]
/// 와 맞춘다.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    required this.selected,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.s14,
      vertical: AppSpacing.s12,
    ),
    super.key,
  });

  /// 선택 여부. true 면 브랜드 보더로 강조한다.
  final bool selected;

  final Widget child;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderRadius = BorderRadius.circular(AppRadius.r10);

    return Material(
      color: selected ? colors.surfaceContainer : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
        borderRadius: borderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// 시트 안의 섹션 제목. (예: `채널 유형`, `공개 범위`)
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppFont.subtextS.copyWith(
        fontWeight: AppFont.semiBold,
        color: context.colors.onSurfaceVariant,
      ),
    );
  }
}

/// 채널 생성 바텀시트.
///
/// Figma `Modal / 채널 만들기` 웹 스펙을 시트 형태로 옮겼다. 채널 유형·이름·공개
/// 범위를 받고, `채널 만들기` 를 누르면 [teamId] 팀에 채널을 만든다. 만드는 동안은
/// 입력과 닫기를 잠그고, 실패하면 입력값을 둔 채 사유를 보여 다시 시도하게 한다.
/// 성공하면 서버가 만든 채널([NewChannelResult])을 돌려주며 닫힌다.
///
/// ponytail: 입력값은 시트가 닫히면 버려지는 화면 로컬 상태라 setState 로 들고,
/// 서버 요청 상태만 [CommandBloc] 이 맡는다. 생성 중·실패를 홈 상태에 실으면 홈
/// 전체가 로딩 화면으로 바뀌고 시트 입력값도 사라지므로, 시트와 같이 생기고 같이
/// 버려지는 Bloc 을 따로 둔다.
class NewChannelSheet extends StatefulWidget {
  const NewChannelSheet({required this.teamId, super.key});

  /// 채널을 만들 팀.
  final int teamId;

  /// 시트를 띄우고 만든 채널을 돌려준다. 만들지 않고 닫으면 null.
  ///
  /// [projectId] 를 주면 만든 채널을 그 프로젝트에 넣는다.
  static Future<NewChannelResult?> show(
    BuildContext context, {
    required int teamId,
    int? projectId,
  }) {
    final repository = context.read<ChannelRepository>();

    Future<NewChannelResult> create(CreateChannelRequest request) async {
      try {
        final channel = await repository.createChannel(
          request,
          projectId: projectId,
        );
        return (channel: channel, projectFailed: false);
      } on ChannelProjectLinkFailure catch (e, s) {
        Logger.e('채널을 프로젝트에 넣지 못함', tag: 'Chat', error: e, stackTrace: s);
        return (channel: e.channel, projectFailed: true);
      }
    }

    return CreateSheet.show<NewChannelResult>(
      context,
      (_) => BlocProvider(
        create: (_) => _CreateChannel(create, tag: 'Chat'),
        child: NewChannelSheet(teamId: teamId),
      ),
    );
  }

  /// 채널 유형 목록. 시안의 이모지는 같은 뜻의 Material 아이콘으로 옮겼다.
  static const types = [
    (
      type: ChannelType.chat,
      label: '일반 채팅',
      description: '텍스트·음성 대화',
      icon: Icons.tag,
    ),
    (
      type: ChannelType.webhook,
      label: 'GitHub 웹훅',
      description: '커밋·PR·이슈 이벤트',
      icon: Icons.webhook,
    ),
    (
      type: ChannelType.file,
      label: '파일',
      description: '업로드·아카이브',
      icon: Icons.folder_outlined,
    ),
    (
      type: ChannelType.accountShare,
      label: '계정 공유',
      description: '팀 공용 계정',
      icon: Icons.key_outlined,
    ),
    (
      type: ChannelType.meetingNote,
      label: '회의록',
      description: '회의 기록·템플릿',
      icon: AppIcon.navNote,
    ),
    (
      type: ChannelType.voice,
      label: '음성',
      description: '실시간 음성',
      icon: Icons.volume_up_outlined,
    ),
  ];

  /// 공개 범위 선택지. 앞의 이모지는 시안대로 라벨 텍스트에 포함한다.
  static const visibilities = [
    (isPrivate: false, label: '🌐 공개', description: '팀 전체 접근'),
    (isPrivate: true, label: '🔒 비공개', description: '초대된 멤버만'),
  ];

  @override
  State<NewChannelSheet> createState() => _NewChannelSheetState();
}

class _NewChannelSheetState extends State<NewChannelSheet> {
  ChannelType _type = ChannelType.chat;
  String _name = '';
  bool _isPrivate = false;

  /// 이름이 있어야 채널을 만들 수 있다.
  bool get _canSubmit => _name.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<_CreateChannel, AsyncState<NewChannelResult>>(
      listener: (context, state) {
        if (state case AsyncSuccess(:final data)) {
          Navigator.of(context).pop(data);
        }
      },
      builder: (context, state) {
        // 성공 직후 닫히기 전 한 프레임도 잠가 둔다.
        final submitting = state is AsyncLoading || state is AsyncSuccess;

        return CreateSheet(
          title: '새 채널',
          dismissible: !submitting,
          children: [
            const _SectionLabel('채널 유형'),
            Column(
              spacing: AppSpacing.s8,
              children: [
                for (final entry in NewChannelSheet.types)
                  CoworkOptionCard(
                    label: entry.label,
                    description: entry.description,
                    icon: entry.icon,
                    selected: entry.type == _type,
                    onTap: submitting
                        ? null
                        : () => setState(() => _type = entry.type),
                  ),
              ],
            ),
            CoworkTextField(
              labelText: '채널 이름',
              hintText: '# 새-채널',
              enabled: !submitting,
              textInputAction: TextInputAction.done,
              onChanged: (value) => setState(() => _name = value),
            ),
            const _SectionLabel('공개 범위'),
            Row(
              spacing: AppSpacing.s10,
              children: [
                for (final entry in NewChannelSheet.visibilities)
                  Expanded(
                    child: SelectableCard(
                      selected: entry.isPrivate == _isPrivate,
                      // 공개 범위 카드는 기본 패딩보다 한 단계 낮은 세로 패딩.
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s14,
                        vertical: AppSpacing.s10,
                      ),
                      onTap: submitting
                          ? null
                          : () => setState(() => _isPrivate = entry.isPrivate),
                      child: _VisibilityOption(
                        label: entry.label,
                        description: entry.description,
                      ),
                    ),
                  ),
              ],
            ),
            if (state case AsyncFailure(:final message))
              CreateSheetError(
                title: '채널을 만들지 못했어요',
                message: message ?? '잠시 후 다시 시도해 주세요.',
              ),
            SizedBox(
              width: double.infinity,
              child: CoworkButton(
                label: submitting ? '채널 생성 중…' : '채널 만들기',
                size: CoworkButtonSize.large,
                enabled: _canSubmit && !submitting,
                onPressed: () => context.read<_CreateChannel>().add(
                  CommandEvent.run(
                    CreateChannelRequest.of(
                      teamId: widget.teamId,
                      name: _name.trim(),
                      type: _type,
                      isPrivate: _isPrivate,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 공개 범위 카드 안의 제목 + 설명.
class _VisibilityOption extends StatelessWidget {
  const _VisibilityOption({required this.label, required this.description});

  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // labelXs(13px) 에 height:null 로 시안의 폰트 기본 행간을 적용.
          style: AppFont.labelXs.copyWith(
            height: null,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // subtextS(12px) 를 시안(11px)에 맞춘다.
          style: AppFont.subtextS.copyWith(
            fontSize: 11,
            height: null,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 프로젝트(채널 카테고리) 생성 바텀시트.
///
/// 웹 `프로젝트 만들기` 모달과 같은 항목(이름, 선택 설명)을 받는다. 서버에 템플릿(채널
/// 자동 구성) API 가 없어 시안의 템플릿 선택은 뺐다. 팀 시트처럼 만드는 동안은 입력과
/// 닫기를 잠그고, 실패하면 입력값을 둔 채 사유를 보여준다. 성공하면 서버가 만든
/// 프로젝트를 돌려주며 닫힌다.
class NewProjectSheet extends StatefulWidget {
  const NewProjectSheet({required this.teamId, super.key});

  /// 프로젝트를 만들 팀.
  final int teamId;

  /// 시트를 띄우고 만든 프로젝트를 돌려준다. 만들지 않고 닫으면 null.
  static Future<ProjectSummaryResponse?> show(
    BuildContext context, {
    required int teamId,
  }) {
    final repository = context.read<ProjectRepository>();
    return CreateSheet.show<ProjectSummaryResponse>(
      context,
      (_) => BlocProvider(
        create: (_) => _CreateProject(repository.createProject, tag: 'Chat'),
        child: NewProjectSheet(teamId: teamId),
      ),
    );
  }

  @override
  State<NewProjectSheet> createState() => _NewProjectSheetState();
}

class _NewProjectSheetState extends State<NewProjectSheet> {
  String _name = '';
  String _description = '';

  /// 이름이 있어야 프로젝트를 만들 수 있다.
  bool get _canSubmit => _name.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<_CreateProject, AsyncState<ProjectSummaryResponse>>(
      listener: (context, state) {
        if (state case AsyncSuccess(:final data)) {
          Navigator.of(context).pop(data);
        }
      },
      builder: (context, state) {
        // 성공 직후 닫히기 전 한 프레임도 잠가 둔다.
        final submitting = state is AsyncLoading || state is AsyncSuccess;
        final description = _description.trim();

        return CreateSheet(
          title: '새 프로젝트',
          dismissible: !submitting,
          children: [
            CoworkTextField(
              labelText: '프로젝트 이름',
              hintText: '새 프로젝트',
              enabled: !submitting,
              textInputAction: TextInputAction.next,
              onChanged: (value) => setState(() => _name = value),
            ),
            CoworkTextField(
              labelText: '프로젝트 설명',
              hintText: '어떤 프로젝트인지 한 줄로 적어보세요 (선택)',
              enabled: !submitting,
              textInputAction: TextInputAction.done,
              onChanged: (value) => setState(() => _description = value),
            ),
            if (state case AsyncFailure(:final message))
              CreateSheetError(
                title: '프로젝트를 만들지 못했어요',
                message: message ?? '잠시 후 다시 시도해 주세요.',
              ),
            SizedBox(
              width: double.infinity,
              child: CoworkButton(
                label: submitting ? '프로젝트 생성 중…' : '프로젝트 만들기',
                size: CoworkButtonSize.large,
                enabled: _canSubmit && !submitting,
                onPressed: () => context.read<_CreateProject>().add(
                  CommandEvent.run(
                    CreateProjectRequest(
                      teamId: widget.teamId,
                      name: _name.trim(),
                      description: description.isEmpty ? null : description,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
