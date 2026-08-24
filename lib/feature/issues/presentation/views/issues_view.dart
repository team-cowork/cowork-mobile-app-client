import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../data/issues_store.dart';
import '../../domain/enums/issue_status.dart';
import '../../domain/issue.dart';
import '../viewModels/issues_bloc.dart';
import '../widgets/issue_card.dart';
import '../widgets/issue_color_mapping.dart';
import '../widgets/issues_header.dart';
import '../widgets/new_issue_sheet.dart';

class IssuesView extends StatefulWidget {
  const IssuesView({super.key});

  @override
  State<IssuesView> createState() => _IssuesViewState();
}

class _IssuesViewState extends State<IssuesView> {
  IssueStatus _selected = IssueStatus.planned;

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<IssuesBloc, List<Issue>>(
      create: (_) => IssuesBloc()..add(const IssuesRequested()),
      errorTitle: '이슈를 불러오지 못했어요',
      onRetry: (context) => context.read<IssuesBloc>().add(const IssuesRequested()),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          backgroundColor: AppColors.red400,
          shape: const CircleBorder(),
          onPressed: () => NewIssueSheet.show(context),
          child: AppIcon.plus(size: 26),
        ),
      ),
      builder: (context, issues) {
        final filtered = issues.where((i) => i.status == _selected).toList();

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IssuesHeader(projectLabel: IssuesStore.instance.projectLabel),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: CoworkSegmentedControl<IssueStatus>(
                  groupValue: _selected,
                  onChanged: (status) => setState(() => _selected = status),
                  segments: [
                    for (final status in IssueStatus.values)
                      CoworkSegment(
                        value: status,
                        label:
                            '${status.label} ${issues.where((i) => i.status == status).length}',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          child: CoworkEmptyState(
                            icon: Icons.view_kanban_outlined,
                            title: '${_selected.label} 이슈가 없어요',
                            description: '새 이슈를 만들어 시작해보세요.',
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.s10),
                        itemBuilder: (context, index) => IssueCard(
                          issue: filtered[index],
                          onTap: () => context.push(
                            '/issues/detail',
                            extra: filtered[index],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
