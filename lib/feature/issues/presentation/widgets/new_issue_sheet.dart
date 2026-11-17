import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/issue_repository.dart';
import '../../domain/issue_target.dart';
import '../blocs/issues/issues_bloc.dart';
import '../blocs/new_issue/new_issue_bloc.dart';
import 'issue_label_toggle.dart';

class NewIssueSheet extends StatelessWidget {
  const NewIssueSheet({super.key});

  static const double _sheetRadius = 22;

  /// 시트를 띄운다. [context]는 [IssuesBloc] 하위여야 한다.
  static Future<void> show(BuildContext context, IssueTarget target) {
    final issuesBloc = context.read<IssuesBloc>();
    final repository = context.read<IssueRepository>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.neutral800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
      ),
      builder: (_) => BlocProvider.value(
        value: issuesBloc,
        child: BlocProvider(
          create: (_) =>
              NewIssueBloc(repository, target)
                ..add(const NewIssueEvent.labelsRequested()),
          child: const NewIssueSheet(),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final form = context.read<NewIssueBloc>().state;
    context.read<IssuesBloc>().add(
      IssuesEvent.created(
        title: form.title,
        body: form.body,
        label: form.label,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NewIssueBloc>();

    return SafeArea(
      child: Padding(
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
                    color: AppColors.neutral700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '새 이슈',
                    style: AppFont.titleS.copyWith(
                      color: AppColors.darkOnSurface,
                    ),
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
                hintText: '이슈 제목을 입력하세요',
                textInputAction: TextInputAction.next,
                onChanged: (value) =>
                    bloc.add(NewIssueEvent.titleChanged(value)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.s8,
                children: [
                  Text(
                    '내용',
                    style: AppFont.subtextS.copyWith(
                      fontWeight: AppFont.semiBold,
                      color: AppColors.neutral300,
                    ),
                  ),
                  CoworkTextArea(
                    hintText: '이슈 내용을 입력하세요 (선택)',
                    minLines: 3,
                    onChanged: (value) =>
                        bloc.add(NewIssueEvent.bodyChanged(value)),
                  ),
                ],
              ),
              BlocBuilder<NewIssueBloc, NewIssueForm>(
                buildWhen: (previous, current) =>
                    previous.labels != current.labels ||
                    previous.label != current.label,
                builder: (context, form) {
                  if (form.labels.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.s8,
                    children: [
                      Text(
                        '라벨',
                        style: AppFont.subtextS.copyWith(
                          fontWeight: AppFont.semiBold,
                          color: AppColors.neutral300,
                        ),
                      ),
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: [
                          for (final name in form.labels)
                            IssueLabelToggle(
                              name: name,
                              selected: name == form.label,
                              onTap: () =>
                                  bloc.add(NewIssueEvent.labelToggled(name)),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              BlocBuilder<NewIssueBloc, NewIssueForm>(
                buildWhen: (previous, current) =>
                    previous.canSubmit != current.canSubmit,
                builder: (context, form) => SizedBox(
                  width: double.infinity,
                  child: CoworkButton(
                    label: '이슈 만들기',
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
