import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/profile_entity.dart';
import '../../data/issues_store.dart';
import '../../domain/enums/issue_priority.dart';
import '../../domain/enums/issue_status.dart';
import '../../domain/enums/issue_tag_color.dart';
import '../../domain/issue.dart';
import '../../domain/issue_label.dart';
import '../viewModels/issues_bloc.dart';
import '../viewModels/new_issue_bloc.dart';
import 'issue_color_mapping.dart';

class NewIssueSheet extends StatelessWidget {
  const NewIssueSheet({super.key});

  static const double _sheetRadius = 22;

  static const _labelCandidates = [
    IssueLabel(name: '기능', color: IssueTagColor.blue),
    IssueLabel(name: '버그', color: IssueTagColor.red),
    IssueLabel(name: '개선', color: IssueTagColor.green),
  ];

  static const _assigneeCandidates = [
    ProfileEntity(id: 101, name: 'junjuny', avatarInitial: '준'),
    ProfileEntity(id: 102, name: '도윤', avatarInitial: '도'),
    ProfileEntity(id: 103, name: '서연', avatarInitial: '서'),
  ];

  static Color _avatarColorFor(int index) => switch (index) {
    0 => AppColors.blue500,
    1 => AppColors.green500,
    _ => AppColors.amber500,
  };

  /// 시트를 띄운다. [context]는 [IssuesBloc] 하위여야 한다.
  static Future<void> show(BuildContext context) {
    final issuesBloc = context.read<IssuesBloc>();

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
          create: (_) => NewIssueBloc(),
          child: const NewIssueSheet(),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final form = context.read<NewIssueBloc>().state;
    final label = _labelCandidates[form.labelIndex];
    final assignee = form.assigneeIndex == null
        ? null
        : _assigneeCandidates[form.assigneeIndex!];

    final dueDate = form.dueDate.trim();
    final milestone = form.milestone.trim();

    context.read<IssuesBloc>().add(
      IssuesEvent.added(
        Issue(
          id: 'issue-${DateTime.now().microsecondsSinceEpoch}',
          number: IssuesStore.instance.nextNumber,
          title: form.title.trim(),
          labels: [label],
          status: form.status,
          assignee: assignee,
          priority: form.priority,
          dueDate: dueDate.isEmpty ? null : dueDate,
          milestone: milestone.isEmpty ? null : milestone,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NewIssueBloc>();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
                    style: AppFont.titleS.copyWith(color: AppColors.darkOnSurface),
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
                textInputAction: TextInputAction.done,
                onChanged: (value) =>
                    bloc.add(NewIssueEvent.titleChanged(value)),
              ),
              BlocBuilder<NewIssueBloc, NewIssueForm>(
                buildWhen: (previous, current) =>
                    previous.status != current.status,
                builder: (context, form) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.s8,
                  children: [
                    Text(
                      '상태',
                      style: AppFont.subtextS.copyWith(
                        fontWeight: AppFont.semiBold,
                        color: AppColors.neutral300,
                      ),
                    ),
                    CoworkSegmentedControl<IssueStatus>(
                      groupValue: form.status,
                      onChanged: (value) =>
                          bloc.add(NewIssueEvent.statusChanged(value)),
                      segments: [
                        for (final status in IssueStatus.values)
                          CoworkSegment(value: status, label: status.label),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
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
                  BlocBuilder<NewIssueBloc, NewIssueForm>(
                    buildWhen: (previous, current) =>
                        previous.labelIndex != current.labelIndex,
                    builder: (context, form) => Row(
                      spacing: AppSpacing.s8,
                      children: [
                        for (final (index, candidate) in _labelCandidates.indexed)
                          _LabelToggle(
                            label: candidate,
                            selected: index == form.labelIndex,
                            onTap: () =>
                                bloc.add(NewIssueEvent.labelChanged(index)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.s8,
                children: [
                  Text(
                    '담당자',
                    style: AppFont.subtextS.copyWith(
                      fontWeight: AppFont.semiBold,
                      color: AppColors.neutral300,
                    ),
                  ),
                  BlocBuilder<NewIssueBloc, NewIssueForm>(
                    buildWhen: (previous, current) =>
                        previous.assigneeIndex != current.assigneeIndex,
                    builder: (context, form) => Row(
                      spacing: AppSpacing.s8,
                      children: [
                        for (final (
                          index,
                          candidate,
                        ) in _assigneeCandidates.indexed)
                          _AssigneeAvatar(
                            profile: candidate,
                            color: _avatarColorFor(index),
                            selected: index == form.assigneeIndex,
                            onTap: () => bloc.add(
                              NewIssueEvent.assigneeToggled(index),
                            ),
                          ),
                        const _AddAssigneeButton(),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.s8,
                children: [
                  Text(
                    '우선순위',
                    style: AppFont.subtextS.copyWith(
                      fontWeight: AppFont.semiBold,
                      color: AppColors.neutral300,
                    ),
                  ),
                  BlocBuilder<NewIssueBloc, NewIssueForm>(
                    buildWhen: (previous, current) =>
                        previous.priority != current.priority,
                    builder: (context, form) => CoworkSegmentedControl<
                      IssuePriority
                    >(
                      groupValue: form.priority,
                      onChanged: (value) =>
                          bloc.add(NewIssueEvent.priorityChanged(value)),
                      segments: [
                        for (final priority in IssuePriority.values)
                          CoworkSegment(
                            value: priority,
                            label: priority.label,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              CoworkTextField(
                labelText: '마감일',
                hintText: '예: 2026.03.20',
                onChanged: (value) =>
                    bloc.add(NewIssueEvent.dueDateChanged(value)),
              ),
              CoworkTextField(
                labelText: '마일스톤',
                hintText: '예: MVP · 1차',
                onChanged: (value) =>
                    bloc.add(NewIssueEvent.milestoneChanged(value)),
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

class _LabelToggle extends StatelessWidget {
  const _LabelToggle({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final IssueLabel label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = label.color!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected ? color.background : AppColors.neutral750,
          border: Border.all(
            color: selected ? color.foreground : AppColors.neutral700,
          ),
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
        child: Text(
          label.name,
          style: AppFont.labelXs.copyWith(
            fontSize: 13,
            color: selected ? color.foreground : AppColors.neutral300,
          ),
        ),
      ),
    );
  }
}

class _AssigneeAvatar extends StatelessWidget {
  const _AssigneeAvatar({
    required this.profile,
    required this.color,
    required this.selected,
    this.onTap,
  });

  final ProfileEntity profile;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(selected ? 2 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: AppColors.red400, width: 2)
              : null,
        ),
        child: CoworkAvatar(
          initials: profile.avatarInitial,
          size: 32,
          backgroundColor: color,
          foregroundColor: AppColors.white,
        ),
      ),
    );
  }
}

class _AddAssigneeButton extends StatelessWidget {
  const _AddAssigneeButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.neutral750,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.neutral700,
          style: BorderStyle.solid,
        ),
      ),
      child: AppIcon.plus(size: 16),
    );
  }
}
