import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/command_bloc.dart';
import '../../../../shared/widgets/base_scaffold.dart';
import '../../../../shared/widgets/create_sheet.dart';
import '../../../../shared/widgets/settings_section.dart';
import '../../../../shared/widgets/settings_tile.dart';
import '../../data/model/requests/template_section_request.dart';
import '../../data/repositories/note_template_repository.dart';
import '../../domain/enums/note_section_type.dart';
import '../../domain/note_template.dart';
import '../blocs/note_template_edit/note_template_edit_bloc.dart';
import '../widgets/note_choice_chip.dart';
import '../widgets/note_section_type_label.dart';
import '../widgets/template_name_sheet.dart';

/// 템플릿 편집 화면.
///
/// Figma `App / 템플릿 편집` 스펙. 이름·기본 템플릿·섹션 구성·삭제를 다룬다. 고친
/// 내용은 누를 때마다 바로 서버에 반영된다. 서버 API 가 이름·섹션을 따로 고치게
/// 되어 있어서, 한 번에 모아 저장하면 일부만 실패했을 때 되돌릴 방법이 없다.
class NoteTemplateEditView extends StatelessWidget {
  const NoteTemplateEditView({super.key, required this.template});

  final NoteTemplate template;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NoteTemplateEditBloc(
        template,
        context.read<NoteTemplateRepository>(),
      ),
      child: BlocConsumer<NoteTemplateEditBloc, NoteTemplateEditState>(
        listenWhen: (previous, current) =>
            current.deleted || current.error != null,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          if (state.error case final error?) {
            messenger.showSnackBar(SnackBar(content: Text(error)));
            return;
          }
          messenger.showSnackBar(const SnackBar(content: Text('템플릿을 삭제했어요.')));
          context.pop();
        },
        builder: (context, state) => BaseScaffold(
          appBar: CoworkAppBar.detail(title: '템플릿 편집'),
          body: _TemplateEditBody(state: state),
        ),
      ),
    );
  }
}

class _TemplateEditBody extends StatelessWidget {
  const _TemplateEditBody({required this.state});

  final NoteTemplateEditState state;

  NoteTemplate get _template => state.template;

  Future<void> _rename(BuildContext context) async {
    final bloc = context.read<NoteTemplateEditBloc>();
    final repository = context.read<NoteTemplateRepository>();
    final renamed = await TemplateNameSheet.show(
      context,
      title: '이름 수정',
      actionLabel: '저장',
      initialName: _template.name,
      submit: (name) => repository.renameTemplate(_template, name),
    );
    if (renamed != null) bloc.add(NoteTemplateChanged(renamed));
  }

  /// [section] 이 있으면 고치고, 없으면 새로 추가한다.
  Future<void> _editSection(
    BuildContext context, [
    NoteTemplateSection? section,
  ]) async {
    final bloc = context.read<NoteTemplateEditBloc>();
    final saved = await _SectionSheet.show(context, _template, section);
    if (saved != null) bloc.add(NoteTemplateSectionSaved(saved));
  }

  Future<void> _deleteSection(
    BuildContext context,
    NoteTemplateSection section,
  ) async {
    final bloc = context.read<NoteTemplateEditBloc>();
    final confirmed = await CoworkDialog.show(
      context,
      title: '‘${section.title}’ 섹션을 삭제할까요?',
      message: '이미 쓴 회의록의 내용은 지워지지 않고 ‘템플릿에 없는 섹션’으로 남아요.',
      confirmLabel: '삭제',
      cancelLabel: '취소',
      confirmColor: CoworkButtonColor.danger,
    );
    if (confirmed == true) bloc.add(NoteTemplateSectionDeleted(section.id));
  }

  Future<void> _deleteTemplate(BuildContext context) async {
    final bloc = context.read<NoteTemplateEditBloc>();
    final confirmed = await CoworkDialog.show(
      context,
      title: '템플릿을 삭제할까요?',
      // 서버는 회의록이 하나라도 있는 템플릿의 삭제를 400 으로 거절한다.
      message: '이 템플릿으로 쓴 회의록이 있으면 삭제할 수 없어요.',
      confirmLabel: '삭제',
      cancelLabel: '취소',
      confirmColor: CoworkButtonColor.danger,
    );
    if (confirmed == true) bloc.add(const NoteTemplateDeleteRequested());
  }

  @override
  Widget build(BuildContext context) {
    final busy = state.busy;
    final isDefault = _template.isDefault;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s24,
      ),
      children: [
        SettingsSection(
          title: '템플릿',
          children: [
            SettingsTile(
              label: '이름',
              trailing: SettingsTrailingValue(value: _template.name),
              onTap: busy ? null : () => _rename(context),
            ),
            SettingsTile(
              label: '기본 템플릿',
              trailing: isDefault
                  ? const CoworkBadge(
                      label: '사용 중',
                      color: CoworkBadgeColor.brand,
                    )
                  : CoworkButton(
                      label: '기본으로 설정',
                      variant: CoworkButtonVariant.weak,
                      enabled: !busy,
                      onPressed: () => context.read<NoteTemplateEditBloc>().add(
                        const NoteTemplateDefaultRequested(),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s20),
        SettingsSection(
          title: '섹션 구성',
          children: [
            if (_template.sections.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s14),
                child: Text(
                  '아직 섹션이 없어요. 섹션을 추가해 회의록 양식을 만들어 주세요.',
                  style: AppFont.subtextM.copyWith(color: AppColors.neutral300),
                ),
              ),
            for (final section in _template.sections)
              _SectionRow(
                section: section,
                onTap: busy ? null : () => _editSection(context, section),
                onDelete: busy ? null : () => _deleteSection(context, section),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s10),
        _AddSectionButton(onTap: busy ? null : () => _editSection(context)),
        const SizedBox(height: AppSpacing.s8),
        Text(
          '섹션은 추가한 순서대로 보여요. 행을 누르면 수정할 수 있어요.',
          style: AppFont.subtextS.copyWith(color: AppColors.neutral400),
        ),
        const SizedBox(height: AppSpacing.s20),
        SettingsSection(
          title: '위험 구역',
          children: [
            // 기본 템플릿은 서버가 삭제를 거절한다(400). 보내기 전에 막는다.
            Opacity(
              opacity: isDefault ? 0.4 : 1,
              child: SettingsTile(
                label: '템플릿 삭제',
                destructive: true,
                onTap: isDefault || busy
                    ? null
                    : () => _deleteTemplate(context),
              ),
            ),
          ],
        ),
        if (isDefault) ...[
          const SizedBox(height: AppSpacing.s8),
          Text(
            '기본 템플릿은 삭제할 수 없어요. 다른 템플릿을 기본으로 바꾼 뒤 삭제하세요.',
            style: AppFont.subtextS.copyWith(color: AppColors.neutral400),
          ),
        ],
      ],
    );
  }
}

/// 섹션 구성 카드의 한 행. 제목 · `형식 · 필수` 와 삭제 버튼으로 구성된다.
class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.section, this.onTap, this.onDelete});

  final NoteTemplateSection section;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s14,
          AppSpacing.s10,
          AppSpacing.s6,
          AppSpacing.s10,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    section.title,
                    style: AppFont.subtextL.copyWith(
                      fontWeight: AppFont.semiBold,
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  Text(
                    section.isRequired
                        ? '${section.type.label} · 필수'
                        : section.type.label,
                    style: AppFont.subtextS.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
                ],
              ),
            ),
            CoworkIconButton(
              icon: Icons.delete_outline,
              size: CoworkIconButtonSize.small,
              variant: CoworkIconButtonVariant.ghost,
              color: CoworkIconButtonColor.neutral,
              semanticLabel: '${section.title} 섹션 삭제',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// `+ 섹션 추가` 버튼. 섹션 카드 아래 테두리만 있는 넓은 버튼.
class _AddSectionButton extends StatelessWidget {
  const _AddSectionButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.r12);

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.neutral700),
        borderRadius: radius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
          child: Center(
            child: Text(
              '+ 섹션 추가',
              style: AppFont.subtextM.copyWith(
                fontWeight: AppFont.semiBold,
                color: AppColors.neutral300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 섹션 하나를 서버에 추가하거나 고치는 [CommandBloc].
typedef _SubmitSection =
    CommandBloc<TemplateSectionRequest, NoteTemplateSection>;

/// 섹션 추가·수정 바텀시트.
///
/// Figma `App / 섹션 편집 (시트)` 스펙. 제목·입력 형식·안내 문구·필수 여부를 받아
/// 바로 서버에 보낸다. 보내는 동안은 입력과 닫기를 잠그고, 실패하면 입력값을 둔 채
/// 사유를 보여준다. 성공하면 서버가 돌려준 섹션을 돌려주며 닫힌다.
class _SectionSheet extends StatefulWidget {
  const _SectionSheet({this.section});

  /// 고칠 섹션. null 이면 새 섹션을 추가한다.
  final NoteTemplateSection? section;

  static Future<NoteTemplateSection?> show(
    BuildContext context,
    NoteTemplate template,
    NoteTemplateSection? section,
  ) {
    final repository = context.read<NoteTemplateRepository>();
    return CreateSheet.show<NoteTemplateSection>(
      context,
      (_) => BlocProvider(
        create: (_) => _SubmitSection(
          (request) => section == null
              ? repository.addSection(template, request)
              : repository.updateSection(template, section.id, request),
          tag: 'NoteTemplates',
        ),
        child: _SectionSheet(section: section),
      ),
    );
  }

  @override
  State<_SectionSheet> createState() => _SectionSheetState();
}

class _SectionSheetState extends State<_SectionSheet> {
  late final _title = TextEditingController(text: widget.section?.title);
  late final _placeholder = TextEditingController(
    text: widget.section?.placeholder,
  );
  late var _type = widget.section?.type ?? NoteSectionType.markdown;
  late var _isRequired = widget.section?.isRequired ?? false;

  bool get _isNew => widget.section == null;

  @override
  void dispose() {
    _title.dispose();
    _placeholder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<_SubmitSection, AsyncState<NoteTemplateSection>>(
      listener: (context, state) {
        if (state case AsyncSuccess(:final data)) {
          Navigator.of(context).pop(data);
        }
      },
      builder: (context, state) {
        // 성공 직후 닫히기 전 한 프레임도 잠가 둔다.
        final submitting = state is AsyncLoading || state is AsyncSuccess;
        final colors = context.colors;

        return CreateSheet(
          title: _isNew ? '섹션 추가' : '섹션 수정',
          dismissible: !submitting,
          children: [
            CoworkTextField(
              controller: _title,
              labelText: '제목',
              hintText: '예: 안건',
              enabled: !submitting,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s8,
              children: [
                Text(
                  '입력 형식',
                  style: AppFont.subtextS.copyWith(
                    fontWeight: AppFont.semiBold,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s8,
                  children: [
                    for (final type in NoteSectionType.values)
                      NoteChoiceChip(
                        label: type.label,
                        selected: type == _type,
                        onTap: submitting
                            ? null
                            : () => setState(() => _type = type),
                      ),
                  ],
                ),
              ],
            ),
            CoworkTextField(
              controller: _placeholder,
              labelText: '안내 문구',
              hintText: '비어 있을 때 보일 문구 (선택)',
              enabled: !submitting,
              textInputAction: TextInputAction.done,
            ),
            _RequiredToggle(
              value: _isRequired,
              onChanged: submitting
                  ? null
                  : (value) => setState(() => _isRequired = value),
            ),
            if (state case AsyncFailure(:final message))
              CreateSheetError(
                title: '섹션을 저장하지 못했어요',
                message: message ?? '잠시 후 다시 시도해 주세요.',
              ),
            SizedBox(
              width: double.infinity,
              child: CoworkButton(
                label: submitting ? '저장 중…' : (_isNew ? '추가' : '저장'),
                size: CoworkButtonSize.large,
                enabled: _title.text.trim().isNotEmpty && !submitting,
                onPressed: () => context.read<_SubmitSection>().add(
                  CommandEvent.run(
                    TemplateSectionRequest.of(
                      title: _title.text.trim(),
                      type: _type,
                      placeholder: _placeholder.text.trim(),
                      isRequired: _isRequired,
                      previousPlaceholder: widget.section?.placeholder,
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

/// `필수 입력` 토글 카드.
class _RequiredToggle extends StatelessWidget {
  const _RequiredToggle({required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        border: Border.all(color: AppColors.neutral700),
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        spacing: AppSpacing.s12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  '필수 입력',
                  style: AppFont.labelXs.copyWith(
                    fontWeight: AppFont.semiBold,
                    color: AppColors.darkOnSurface,
                  ),
                ),
                Text(
                  '비어 있으면 회의록을 저장할 수 없어요',
                  style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
                ),
              ],
            ),
          ),
          CoworkSwitch(
            value: value,
            enabled: onChanged != null,
            semanticLabel: '필수 입력',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
