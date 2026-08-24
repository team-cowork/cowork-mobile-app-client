import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/channel_type.dart';

/// 선택 여부를 보더로 표시하는 카드 컨테이너.
///
/// [CoworkOptionCard] 는 `아이콘 + 제목 + 설명` 한 행이 고정이라, 공개 범위나
/// 템플릿처럼 내용 구성이 다른 카드에 쓴다. 배경·보더 규칙은 [CoworkOptionCard]
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

/// 채널·프로젝트 생성 바텀시트의 공통 껍데기.
///
/// 핸들, 제목 + 닫기 버튼, 키보드 회피, 스크롤을 맡는다. 시트마다 다른 입력
/// 항목과 CTA 는 [children] 으로 받는다.
class _CreateSheet extends StatelessWidget {
  const _CreateSheet({required this.title, required this.children});

  final String title;

  /// 입력 항목과 CTA. 세로로 [AppSpacing.s16] 간격을 두고 쌓인다.
  final List<Widget> children;

  static const double _radius = 22;

  /// 시트를 띄우고 시트가 [Navigator.pop] 으로 돌려준 값을 넘겨준다.
  static Future<T?> show<T>(BuildContext context, WidgetBuilder builder) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_radius)),
      ),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
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
                    title,
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
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// 시트 안의 섹션 제목. (예: `채널 유형`, `템플릿`)
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

/// 시트가 돌려주는 입력값.
typedef NewChannelForm = ({ChannelType type, String name, bool isPrivate});

/// 채널 생성 바텀시트.
///
/// Figma `Modal / 채널 만들기` 웹 스펙을 시트 형태로 옮겼다. 채널 유형·이름·공개
/// 범위를 받고, `채널 만들기` 를 누르면 입력값([NewChannelForm])을 돌려주며 닫힌다.
///
/// ponytail: 입력값은 시트가 닫히면 버려지는 화면 로컬 상태라 Bloc 없이 setState 로 든다.
class NewChannelSheet extends StatefulWidget {
  const NewChannelSheet({super.key});

  /// 시트를 띄우고 입력값을 돌려준다. 취소하면 null.
  static Future<NewChannelForm?> show(BuildContext context) {
    return _CreateSheet.show<NewChannelForm>(
      context,
      (_) => const NewChannelSheet(),
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
    return _CreateSheet(
      title: '새 채널',
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
                onTap: () => setState(() => _type = entry.type),
              ),
          ],
        ),
        CoworkTextField(
          labelText: '채널 이름',
          hintText: '# 새-채널',
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
                  // 공개 범위 카드는 템플릿 카드보다 한 단계 낮은 세로 패딩.
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s14,
                    vertical: AppSpacing.s10,
                  ),
                  onTap: () => setState(() => _isPrivate = entry.isPrivate),
                  child: _VisibilityOption(
                    label: entry.label,
                    description: entry.description,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: CoworkButton(
            label: '채널 만들기',
            size: CoworkButtonSize.large,
            enabled: _canSubmit,
            onPressed: () => Navigator.of(
              context,
            ).pop((type: _type, name: _name, isPrivate: _isPrivate)),
          ),
        ),
      ],
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

/// 시트가 돌려주는 입력값. [template]은 [NewProjectSheet.templates] 인덱스.
typedef NewProjectForm = ({int template, String name});

/// 프로젝트 생성 바텀시트.
///
/// Figma `Modal / 프로젝트 만들기` 웹 스펙을 시트 형태로 옮겼다. 템플릿과 이름을
/// 받고, `프로젝트 만들기` 를 누르면 입력값([NewProjectForm])을 돌려주며 닫힌다.
///
/// ponytail: 입력값은 시트가 닫히면 버려지는 화면 로컬 상태라 Bloc 없이 setState 로 든다.
class NewProjectSheet extends StatefulWidget {
  const NewProjectSheet({super.key});

  /// 시트를 띄우고 입력값을 돌려준다. 취소하면 null.
  static Future<NewProjectForm?> show(BuildContext context) {
    return _CreateSheet.show<NewProjectForm>(
      context,
      (_) => const NewProjectSheet(),
    );
  }

  // ponytail: 템플릿이 만들어 주는 채널 목록은 시안 그대로 박아 둔다. 서버가
  // 템플릿을 내려주게 되면 이 목록을 응답으로 갈아끼운다.
  static const templates = [
    (
      label: '개발 프로젝트',
      meta: '채널 5개 자동 구성',
      channels: ['# 일반', '# 백엔드', '# 프론트엔드', '🔊 데일리', '📝 회의록'],
    ),
    (
      label: '디자인 프로젝트',
      meta: '채널 4개',
      channels: ['# 일반', '# 피드백', '📁 에셋', '📝 회의록'],
    ),
    (label: '운영 프로젝트', meta: '채널 3개', channels: ['# 공지', '🪝 웹훅', '🔑 계정 공유']),
    (label: '빈 프로젝트', meta: '채널 없이 시작', channels: <String>[]),
  ];

  @override
  State<NewProjectSheet> createState() => _NewProjectSheetState();
}

class _NewProjectSheetState extends State<NewProjectSheet> {
  int _template = 0;
  String _name = '';

  /// 이름이 있어야 프로젝트를 만들 수 있다.
  bool get _canSubmit => _name.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return _CreateSheet(
      title: '새 프로젝트',
      children: [
        const _SectionLabel('템플릿'),
        Column(
          spacing: AppSpacing.s8,
          children: [
            for (final (index, template) in NewProjectSheet.templates.indexed)
              SelectableCard(
                selected: index == _template,
                onTap: () => setState(() => _template = index),
                child: _Template(
                  label: template.label,
                  meta: template.meta,
                  channels: template.channels,
                ),
              ),
          ],
        ),
        CoworkTextField(
          labelText: '프로젝트 이름',
          hintText: '새 프로젝트',
          textInputAction: TextInputAction.done,
          onChanged: (value) => setState(() => _name = value),
        ),
        SizedBox(
          width: double.infinity,
          child: CoworkButton(
            label: '프로젝트 만들기',
            size: CoworkButtonSize.large,
            enabled: _canSubmit,
            onPressed: () =>
                Navigator.of(context).pop((template: _template, name: _name)),
          ),
        ),
      ],
    );
  }
}

/// 템플릿 카드 안의 제목 + 채널 수 + 만들어질 채널 칩.
class _Template extends StatelessWidget {
  const _Template({
    required this.label,
    required this.meta,
    required this.channels,
  });

  final String label;

  /// 오른쪽에 붙는 요약. (예: `채널 5개 자동 구성`)
  final String meta;

  /// 템플릿이 만들어 줄 채널 이름. 비어 있으면 칩 줄을 그리지 않는다.
  final List<String> channels;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.s8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // labelXs(13px) 를 시안(14px)에 맞추고, height:null 로 폰트 기본 행간 적용.
                style: AppFont.labelXs.copyWith(
                  fontSize: 14,
                  height: null,
                  color: colors.onSurface,
                ),
              ),
            ),
            Text(
              meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFont.subtextS.copyWith(
                height: null,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (channels.isNotEmpty)
          Wrap(
            spacing: AppSpacing.s6,
            runSpacing: AppSpacing.s6,
            children: [
              for (final channel in channels) _ChannelChip(label: channel),
            ],
          ),
      ],
    );
  }
}

/// 템플릿이 만들어 줄 채널 하나를 나타내는 칩.
class _ChannelChip extends StatelessWidget {
  const _ChannelChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      // ponytail: 시안은 칩 배경도 카드와 같은 토큰이라 미선택 카드에서 칩이 사라진다.
      // 두 상태 모두에서 읽히도록 한 단계 밝은 토큰을 쓴다.
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.r6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      child: Text(
        label,
        style: AppFont.subtextS.copyWith(
          fontSize: 11,
          height: null,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
