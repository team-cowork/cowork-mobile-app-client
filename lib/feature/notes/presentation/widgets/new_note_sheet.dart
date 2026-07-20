import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../viewModels/notes_bloc.dart';

/// 회의록 생성(새 노트) 바텀시트.
///
/// Figma `Sheet / 새 노트` 스펙. 제목·내용 입력과 템플릿 선택을 제공하고,
/// `노트 만들기`를 누르면 [NotesBloc]에 [NoteAdded]를 보낸다.
class NewNoteSheet extends StatelessWidget {
  const NewNoteSheet({super.key});

  /// 시트를 띄운다. [context]는 [NotesBloc] 하위여야 한다.
  static Future<void> show(BuildContext context) {
    final notesBloc = context.read<NotesBloc>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
      ),
      // 시트는 별도 라우트라 목록 Bloc을 직접 넘겨준다.
      builder: (_) => BlocProvider.value(
        value: notesBloc,
        child: BlocProvider(
          create: (_) => NewNoteBloc(),
          child: const NewNoteSheet(),
        ),
      ),
    );
  }

  static const double _sheetRadius = 22;

  static const templates = [
    (label: '자유 양식', description: '빈 문서로 시작'),
    (label: '회의록', description: '안건 · 결정 · 액션 아이템'),
    (label: '스프린트 회고', description: 'Keep · Problem · Try'),
  ];

  void _submit(BuildContext context) {
    // buildWhen 때문에 버튼이 들고 있는 form 은 낡을 수 있어 현재 상태를 읽는다.
    final form = context.read<NewNoteBloc>().state;

    context.read<NotesBloc>().add(
      NoteAdded(
        title: form.title,
        content: form.content,
        template: templates[form.template].label,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bloc = context.read<NewNoteBloc>();

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
                    '새 노트',
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
              CoworkTextField(
                labelText: '제목',
                hintText: '노트 제목을 입력하세요',
                textInputAction: TextInputAction.next,
                onChanged: (value) => bloc.add(NewNoteChanged(title: value)),
              ),
              CoworkTextArea(
                labelText: '내용',
                hintText: '회의 안건과 논의 내용을 적어보세요. 편집 화면에서 이어서 작성할 수 있어요.',
                minLines: 4,
                onChanged: (value) => bloc.add(NewNoteChanged(content: value)),
              ),
              BlocBuilder<NewNoteBloc, NewNoteForm>(
                builder: (context, form) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.s8,
                  children: [
                    Text(
                      '템플릿',
                      style: AppFont.subtextS.copyWith(
                        fontWeight: AppFont.semiBold,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    for (final (index, template) in templates.indexed)
                      CoworkOptionCard(
                        label: template.label,
                        description: template.description,
                        icon: AppIcon.navNote,
                        selected: index == form.template,
                        onTap: () => bloc.add(NewNoteChanged(template: index)),
                        trailing: _TemplateRadio(selected: index == form.template),
                      ),
                  ],
                ),
              ),
              BlocBuilder<NewNoteBloc, NewNoteForm>(
                buildWhen: (previous, current) =>
                    previous.canSubmit != current.canSubmit,
                builder: (context, form) => SizedBox(
                  width: double.infinity,
                  child: CoworkButton(
                    label: '노트 만들기',
                    size: CoworkButtonSize.large,
                    enabled: form.canSubmit,
                    onPressed: () => _submit(context),
                  ),
                ),
              ),
            ],
          ),
        ),
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
