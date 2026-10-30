import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../data/notes_repository.dart';
import '../../data/repositories/note_template_repository.dart';
import '../../domain/note_template.dart';
import '../blocs/note_templates/note_templates_bloc.dart';
import '../widgets/note_choice_chip.dart';
import '../widgets/template_name_sheet.dart';

/// 회의록 템플릿 목록 화면.
///
/// Figma `App / 회의록 템플릿 (목록)` 스펙. 템플릿은 채널마다 따로라 위쪽 칩으로
/// 회의록 채널을 고르고, 그 채널의 템플릿을 카드로 보여준다. 카드를 누르면 편집
/// 화면을, `새 템플릿` 을 누르면 이름을 받아 템플릿을 만든 뒤 편집 화면을 연다.
class NoteTemplatesView extends StatelessWidget {
  const NoteTemplatesView({super.key, this.channelId});

  /// 처음 고를 채널. 새 노트 시트에서 열면 시트가 고른 채널이다.
  final int? channelId;

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<NoteTemplatesBloc, NoteTemplatesData>(
      create: (context) => NoteTemplatesBloc(
        context.read<NotesRepository>(),
        context.read<NoteTemplateRepository>(),
      )..add(NoteTemplatesRequested(channelId: channelId)),
      errorTitle: '템플릿을 불러오지 못했어요',
      onRetry: (context) => context.read<NoteTemplatesBloc>().add(
        NoteTemplatesRequested(channelId: channelId),
      ),
      appBar: CoworkAppBar.detail(
        title: '회의록 템플릿',
        actions: const [_NewTemplateButton()],
      ),
      builder: (context, data) {
        if (data.channels.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s16),
              child: CoworkEmptyState(
                icon: AppIcon.navNote,
                title: '회의록 채널이 없어요',
                description: '채널 탭에서 회의록 채널을 만들면 템플릿을 관리할 수 있어요.',
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s8,
            AppSpacing.s16,
            AppSpacing.s24,
          ),
          children: [
            Text(
              '채널',
              style: AppFont.subtextS.copyWith(
                fontWeight: AppFont.semiBold,
                color: AppColors.neutral300,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: [
                for (final channel in data.channels)
                  NoteChoiceChip(
                    label: '# ${channel.name}',
                    selected: int.parse(channel.id) == data.channelId,
                    onTap: () => context.read<NoteTemplatesBloc>().add(
                      NoteTemplatesRequested(channelId: int.parse(channel.id)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              '새 노트를 만들 때 고르는 양식이에요. 기본 템플릿이 먼저 선택돼요.',
              style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
            ),
            const SizedBox(height: AppSpacing.s16),
            if (data.loadingTemplates)
              const CoworkLoadingPane(height: 96)
            else if (data.templates.isEmpty)
              const CoworkEmptyState(
                icon: AppIcon.navNote,
                title: '템플릿이 없어요',
                description: '새 템플릿으로 이 채널의 첫 양식을 만들어 보세요.',
              ),
            for (final (index, template) in data.templates.indexed) ...[
              if (index > 0) const SizedBox(height: AppSpacing.s10),
              _TemplateCard(template: template),
            ],
          ],
        );
      },
    );
  }

  /// 템플릿 편집 화면을 열고, 돌아오면 그 채널의 템플릿을 다시 읽는다.
  static Future<void> _openEditor(
    BuildContext context,
    NoteTemplate template,
  ) async {
    final bloc = context.read<NoteTemplatesBloc>();
    await context.push<void>('/notes/templates/edit', extra: template);
    bloc.add(NoteTemplatesRequested(channelId: template.channelId));
  }
}

/// `새 템플릿` 버튼. 고른 채널이 있을 때만 누를 수 있다.
class _NewTemplateButton extends StatelessWidget {
  const _NewTemplateButton();

  Future<void> _create(BuildContext context, int channelId) async {
    final repository = context.read<NoteTemplateRepository>();
    final created = await TemplateNameSheet.show(
      context,
      title: '새 템플릿',
      actionLabel: '템플릿 만들기',
      caption: '만든 뒤 편집 화면에서 섹션을 추가할 수 있어요.',
      submit: (name) => repository.createTemplate(channelId, name),
    );
    if (created == null || !context.mounted) return;
    await NoteTemplatesView._openEditor(context, created);
  }

  @override
  Widget build(BuildContext context) {
    final channelId = switch (context.watch<NoteTemplatesBloc>().state) {
      AsyncSuccess(:final data) => data.channelId,
      _ => null,
    };
    return CoworkButton(
      label: '새 템플릿',
      enabled: channelId != null,
      onPressed: channelId == null ? null : () => _create(context, channelId),
    );
  }
}

/// 템플릿 카드 한 장. 이름 · 기본 표시 / 섹션 칩 / 섹션 수로 구성된다.
class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template});

  final NoteTemplate template;

  @override
  Widget build(BuildContext context) {
    final requiredCount = template.sections.where((s) => s.isRequired).length;
    final radius = BorderRadius.circular(AppRadius.r12);

    return Material(
      color: AppColors.neutral800,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: template.isDefault ? AppColors.red400 : AppColors.neutral700,
        ),
        borderRadius: radius,
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: () => NoteTemplatesView._openEditor(context, template),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s14,
            AppSpacing.s12,
            AppSpacing.s14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s10,
            children: [
              Row(
                spacing: AppSpacing.s8,
                children: [
                  Flexible(
                    child: Text(
                      template.name,
                      style: AppFont.labelS.copyWith(
                        fontSize: 15,
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                  ),
                  if (template.isDefault)
                    const CoworkBadge(
                      label: '기본',
                      color: CoworkBadgeColor.brand,
                    ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.neutral300,
                  ),
                ],
              ),
              if (template.sections.isNotEmpty)
                Wrap(
                  spacing: AppSpacing.s6,
                  runSpacing: AppSpacing.s6,
                  children: [
                    for (final section in template.sections)
                      _SectionChip(label: section.title),
                  ],
                ),
              Text(
                template.sections.isEmpty
                    ? '섹션 없음'
                    : '섹션 ${template.sections.length}개'
                          '${requiredCount > 0 ? ' · 필수 $requiredCount개' : ''}',
                style: AppFont.subtextS.copyWith(color: AppColors.neutral400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 템플릿 카드 안의 섹션 제목 칩.
class _SectionChip extends StatelessWidget {
  const _SectionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral750,
        borderRadius: BorderRadius.circular(AppRadius.r6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(
        label,
        style: AppFont.subtextS.copyWith(
          fontSize: 11,
          height: null,
          fontWeight: AppFont.semiBold,
          color: AppColors.neutral300,
        ),
      ),
    );
  }
}
