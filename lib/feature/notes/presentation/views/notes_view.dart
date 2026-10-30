import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/command_bloc.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../../shared/widgets/create_sheet.dart';
import '../../../channel/domain/channel.dart';
import '../../data/notes_repository.dart';
import '../../data/repositories/note_template_repository.dart';
import '../../domain/note.dart';
import '../../domain/note_draft.dart';
import '../../domain/note_template.dart';
import '../blocs/notes/notes_bloc.dart';
import '../widgets/note_choice_chip.dart';

/// 회의록 목록 화면.
///
/// Figma `App / Notes (회의록)` 스펙에 맞춘 다크 전용 레이아웃.
class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<NotesBloc, List<Note>>(
      create: (context) =>
          NotesBloc(context.read<NotesRepository>())
            ..add(const NotesRequested()),
      errorTitle: '회의록을 불러오지 못했어요',
      onRetry: (context) =>
          context.read<NotesBloc>().add(const NotesRequested()),
      appBar: CoworkAppBar.section(
        title: '회의록',
        subtitle: '회의 기록 · 템플릿 기반 작성',
        actions: const [
          _TemplatesButton(),
          SizedBox(width: AppSpacing.s8),
          _NewNoteButton(),
        ],
      ),
      builder: (context, notes) {
        if (notes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s16),
              child: CoworkEmptyState(
                icon: Icons.description_outlined,
                title: '아직 회의록이 없어요',
                description: '첫 회의록을 작성해 팀 기록을 남겨보세요.',
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s12,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          itemCount: notes.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s10),
          itemBuilder: (_, i) => _NoteCard(note: notes[i]),
        );
      },
    );
  }
}

/// `템플릿` 보조 버튼. 회의록 템플릿 관리 화면을 연다.
class _TemplatesButton extends StatelessWidget {
  const _TemplatesButton();

  @override
  Widget build(BuildContext context) {
    return CoworkButton(
      label: '템플릿',
      variant: CoworkButtonVariant.weak,
      color: CoworkButtonColor.neutral,
      onPressed: () => context.push<void>('/notes/templates'),
    );
  }
}

/// `+ 새 노트` 강조 버튼. 시트에서 채널·템플릿·제목을 고르면 편집 화면을 연다.
class _NewNoteButton extends StatelessWidget {
  const _NewNoteButton();

  /// 회의록은 편집 화면에서 저장할 때 만들어진다. 저장하지 않고 나오면 아무것도
  /// 남지 않는다. 작성자·작성일은 서버가 채우므로 목록은 끼워 넣지 않고 다시 읽는다.
  static Future<void> _createNote(BuildContext context) async {
    final bloc = context.read<NotesBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final draft = await _NewNoteSheet.show(context);
    if (draft == null || !context.mounted) return;
    final created = await context.push<Note>('/notes/new', extra: draft);
    if (created == null) return;
    bloc.add(const NotesRequested());
    messenger.showSnackBar(const SnackBar(content: Text('회의록을 만들었어요.')));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _createNote(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.red400,
          borderRadius: BorderRadius.circular(AppRadius.r10),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s12,
          AppSpacing.s8,
          AppSpacing.s14,
          AppSpacing.s8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 16, color: AppColors.white),
            const SizedBox(width: AppSpacing.s4),
            Text(
              '새 노트',
              style: AppFont.subtextM.copyWith(
                fontWeight: AppFont.semiBold,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 회의록 목록의 카드 한 장.
///
/// 제목 + 태그 배지 / 요약 / 작성자·날짜로 구성된다.
/// Figma `App / Notes (회의록)` 스펙에 맞춘 다크 전용 레이아웃.
class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 상세에서 편집하면 서버 회의록이 바뀌므로, 돌아오면 목록을 다시 불러온다.
      onTap: () async {
        await context.push<void>('/notes/detail', extra: note);
        if (context.mounted) {
          context.read<NotesBloc>().add(const NotesRequested());
        }
      },
      child: _card(),
    );
  }

  Widget _card() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        border: Border.all(color: AppColors.neutral700),
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s8,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: AppFont.labelS.copyWith(
                    fontSize: 16,
                    color: AppColors.darkOnSurface,
                  ),
                ),
              ),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.s8),
                Wrap(
                  spacing: AppSpacing.s4,
                  children: [
                    for (final tag in note.tags) CoworkBadge(label: tag),
                  ],
                ),
              ],
            ],
          ),
          Text(
            note.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFont.subtextM.copyWith(
              height: 1.45,
              color: AppColors.neutral300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s4),
            child: _AuthorLine(author: note.author),
          ),
        ],
      ),
    );
  }
}

/// 작성자 아바타(이니셜) + `이름 · 날짜` 라인.
class _AuthorLine extends StatelessWidget {
  const _AuthorLine({required this.author});

  final NoteAuthor author;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColors.neutral600,
            shape: BoxShape.circle,
          ),
          child: author.avatarUrl.isEmpty
              ? _initialFallback()
              : Image.network(
                  author.avatarUrl,
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _initialFallback(),
                ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(
          '${author.name}  ·  ${author.date}',
          style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
        ),
      ],
    );
  }

  Widget _initialFallback() => Text(
    author.initial,
    style: AppFont.labelXs.copyWith(fontSize: 9, color: AppColors.white),
  );
}

/// 내 회의록 채널을 읽는 [CommandBloc]. 인자는 없다.
typedef _LoadChannels = CommandBloc<void, List<Channel>>;

/// 채널 하나의 템플릿을 읽는 [CommandBloc]. 인자는 채널 id 다.
typedef _LoadTemplates = CommandBloc<int, List<NoteTemplate>>;

/// 회의록 생성(새 노트) 바텀시트.
///
/// Figma `App / 새 노트 (모달) — 서버 템플릿` 스펙. 회의록 채널을 고르면 그 채널의
/// 서버 템플릿을 불러와 고르게 하고, 템플릿이 없으면 입력 전에 알린다. 본문은
/// 받지 않는다. 고른 값([NoteDraft])을 돌려주면 목록이 편집 화면을 열고, 회의록은
/// 거기서 저장할 때 만들어진다.
///
/// ponytail: 입력값은 시트가 닫히면 버려지는 화면 로컬 상태라 setState 로 들고,
/// 서버 요청 상태만 [CommandBloc] 이 맡는다.
class _NewNoteSheet extends StatefulWidget {
  const _NewNoteSheet();

  /// 시트를 띄우고 고른 채널·템플릿·제목을 돌려준다. 고르지 않고 닫으면 null.
  static Future<NoteDraft?> show(BuildContext context) {
    final notes = context.read<NotesRepository>();
    final templates = context.read<NoteTemplateRepository>();
    return CreateSheet.show<NoteDraft>(
      context,
      (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                _LoadChannels((_) => notes.fetchNoteChannels(), tag: 'Notes')
                  ..add(const CommandRun<void>(null)),
          ),
          BlocProvider(
            create: (_) =>
                _LoadTemplates(templates.fetchTemplates, tag: 'Notes'),
          ),
        ],
        child: const _NewNoteSheet(),
      ),
    );
  }

  @override
  State<_NewNoteSheet> createState() => _NewNoteSheetState();
}

class _NewNoteSheetState extends State<_NewNoteSheet> {
  int? _channelId;
  int? _templateId;
  String _title = '';

  /// 채널을 바꾸면 고른 템플릿을 비우고 그 채널의 템플릿을 읽는다.
  void _selectChannel(int channelId) {
    setState(() {
      _channelId = channelId;
      _templateId = null;
    });
    context.read<_LoadTemplates>().add(CommandEvent.run(channelId));
  }

  /// 템플릿 관리 화면을 열고, 돌아오면 고친 템플릿을 다시 읽는다.
  Future<void> _manageTemplates() async {
    final channelId = _channelId;
    if (channelId == null) return;
    await context.push<void>('/notes/templates', extra: channelId);
    if (mounted) _selectChannel(channelId);
  }

  /// 읽은 템플릿 중 고른 것이 없으면 기본 템플릿을, 그것도 없으면 첫 템플릿을 고른다.
  void _onTemplatesLoaded(List<NoteTemplate> templates) {
    if (templates.any((template) => template.id == _templateId)) return;
    final picked =
        templates.where((template) => template.isDefault).firstOrNull ??
        templates.firstOrNull;
    setState(() => _templateId = picked?.id);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 채널을 읽으면 첫 채널을 골라 템플릿을 읽는다.
        BlocListener<_LoadChannels, AsyncState<List<Channel>>>(
          listener: (context, state) {
            if (state case AsyncSuccess(:final data) when _channelId == null) {
              if (data.firstOrNull case final first?) {
                _selectChannel(int.parse(first.id));
              }
            }
          },
        ),
        BlocListener<_LoadTemplates, AsyncState<List<NoteTemplate>>>(
          listener: (context, state) {
            if (state case AsyncSuccess(:final data)) _onTemplatesLoaded(data);
          },
        ),
      ],
      child: Builder(builder: _buildSheet),
    );
  }

  Widget _buildSheet(BuildContext context) {
    final channels = context.watch<_LoadChannels>().state;
    final templates = context.watch<_LoadTemplates>().state;

    final loaded = switch (templates) {
      AsyncSuccess(:final data) => data,
      _ => const <NoteTemplate>[],
    };
    final template = loaded.where((t) => t.id == _templateId).firstOrNull;
    final channelId = _channelId;
    final canSubmit =
        _title.trim().isNotEmpty && channelId != null && template != null;

    return CreateSheet(
      title: '새 노트',
      children: [
        ..._channelSection(
          channels,
          // 템플릿을 읽는 중에 채널을 바꾸면 그 요청은 무시되므로 잠가 둔다.
          enabled: templates is! AsyncLoading,
        ),
        if (templates is AsyncSuccess && loaded.isEmpty)
          _SheetNotice(
            title: '이 채널에는 템플릿이 없어요',
            description: '템플릿이 있어야 회의록을 쓸 수 있어요.',
            actionLabel: '템플릿 만들기',
            onAction: _manageTemplates,
          ),
        if (channels case AsyncSuccess(:final data) when data.isNotEmpty)
          CoworkTextField(
            labelText: '제목',
            hintText: '노트 제목을 입력하세요',
            enabled: loaded.isNotEmpty,
            textInputAction: TextInputAction.done,
            onChanged: (value) => setState(() => _title = value),
          ),
        ..._templateSection(templates, loaded),
        SizedBox(
          width: double.infinity,
          child: CoworkButton(
            label: '노트 만들기',
            size: CoworkButtonSize.large,
            enabled: canSubmit,
            onPressed: () => Navigator.of(context).pop<NoteDraft>((
              channelId: channelId!,
              template: template!,
              title: _title.trim(),
            )),
          ),
        ),
      ],
    );
  }

  /// `채널` 라벨 + 회의록 채널 칩. 못 읽었거나 채널이 없으면 그 사유를 보여준다.
  List<Widget> _channelSection(
    AsyncState<List<Channel>> state, {
    required bool enabled,
  }) => switch (state) {
    AsyncSuccess(:final data) when data.isEmpty => const [
      _SheetNotice(
        title: '회의록 채널이 없어요',
        description: '채널 탭에서 회의록 채널을 먼저 만들어 주세요.',
      ),
    ],
    AsyncSuccess(:final data) => [
      const _SheetLabel('채널'),
      Wrap(
        spacing: AppSpacing.s8,
        runSpacing: AppSpacing.s8,
        children: [
          for (final channel in data)
            NoteChoiceChip(
              label: '# ${channel.name}',
              selected: int.parse(channel.id) == _channelId,
              onTap: enabled
                  ? () => _selectChannel(int.parse(channel.id))
                  : null,
            ),
        ],
      ),
    ],
    AsyncFailure(:final message) => [
      CreateSheetError(
        title: '회의록 채널을 불러오지 못했어요',
        message: message ?? '잠시 후 다시 시도해 주세요.',
      ),
      CoworkButton(
        label: '다시 시도',
        variant: CoworkButtonVariant.weak,
        color: CoworkButtonColor.neutral,
        onPressed: () =>
            context.read<_LoadChannels>().add(const CommandRun<void>(null)),
      ),
    ],
    // 스피너(44)와 카드 여백이 들어가는 가장 낮은 높이.
    _ => const [_SheetLabel('채널'), CoworkLoadingPane(height: 80)],
  };

  /// `템플릿 · 관리` 라벨 + 서버 템플릿 카드. 템플릿이 없으면 시트 위쪽 안내가 대신한다.
  List<Widget> _templateSection(
    AsyncState<List<NoteTemplate>> state,
    List<NoteTemplate> templates,
  ) => switch (state) {
    AsyncSuccess() when templates.isEmpty => const [],
    AsyncSuccess() => [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _SheetLabel('템플릿'),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _manageTemplates,
            child: Text(
              '관리',
              style: AppFont.subtextS.copyWith(
                fontWeight: AppFont.semiBold,
                color: AppColors.red400,
              ),
            ),
          ),
        ],
      ),
      for (final template in templates)
        CoworkOptionCard(
          label: template.name,
          description: template.sections.isEmpty
              ? '섹션 없음'
              : template.sections.map((section) => section.title).join(' · '),
          icon: AppIcon.navNote,
          selected: template.id == _templateId,
          onTap: () => setState(() => _templateId = template.id),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.s8,
            children: [
              if (template.isDefault)
                const CoworkBadge(label: '기본', color: CoworkBadgeColor.brand),
              _TemplateRadio(selected: template.id == _templateId),
            ],
          ),
        ),
      Text(
        '만들면 고른 템플릿의 섹션으로 편집 화면이 열려요.',
        style: AppFont.subtextS.copyWith(color: AppColors.neutral400),
      ),
    ],
    AsyncFailure(:final message) => [
      CreateSheetError(
        title: '템플릿을 불러오지 못했어요',
        message: message ?? '잠시 후 다시 시도해 주세요.',
      ),
      CoworkButton(
        label: '다시 시도',
        variant: CoworkButtonVariant.weak,
        color: CoworkButtonColor.neutral,
        onPressed: _channelId == null
            ? null
            : () => _selectChannel(_channelId!),
      ),
    ],
    AsyncLoading() => const [_SheetLabel('템플릿'), CoworkLoadingPane(height: 96)],
    // 채널을 고르기 전.
    _ => const [],
  };
}

/// 시트 안의 섹션 제목. (예: `채널`, `템플릿`)
class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.label);

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

/// 시트에서 더 진행할 수 없는 이유를 알리는 카드. 필요하면 해결 버튼을 단다.
///
/// Figma `App / 새 노트 (모달) — 템플릿 없음` 의 안내 카드.
class _SheetNotice extends StatelessWidget {
  const _SheetNotice({
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        border: Border.all(color: AppColors.neutral700),
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      padding: const EdgeInsets.all(AppSpacing.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s12,
        children: [
          Row(
            spacing: AppSpacing.s12,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.neutral700,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  AppIcon.navNote,
                  size: 18,
                  color: AppColors.neutral300,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      title,
                      style: AppFont.labelXs.copyWith(
                        fontWeight: AppFont.semiBold,
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    Text(
                      description,
                      style: AppFont.subtextS.copyWith(
                        color: AppColors.neutral300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel case final label?)
            CoworkButton(
              label: label,
              size: CoworkButtonSize.medium,
              variant: CoworkButtonVariant.weak,
              onPressed: onAction,
            ),
        ],
      ),
    );
  }
}

/// 템플릿 카드 오른쪽의 라디오 표시.
class _TemplateRadio extends StatelessWidget {
  const _TemplateRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.primary : colors.onSurfaceVariant,
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary,
              ),
            )
          : null,
    );
  }
}
