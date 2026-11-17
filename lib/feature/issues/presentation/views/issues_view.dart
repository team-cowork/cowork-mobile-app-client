import 'dart:async';

import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../data/repositories/issue_repository.dart';
import '../../domain/enums/issue_status.dart';
import '../../domain/issue_detail_args.dart';
import '../blocs/issues/issues_bloc.dart';
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
    return BlocScaffold<IssuesBloc, IssuesData>(
      create: (context) =>
          IssuesBloc(context.read<IssueRepository>())
            ..add(const IssuesEvent.requested()),
      errorTitle: '이슈를 불러오지 못했어요',
      onRetry: (context) =>
          context.read<IssuesBloc>().add(const IssuesEvent.requested()),
      floatingActionButton: Builder(
        builder: (context) => BlocBuilder<IssuesBloc, IssuesState>(
          builder: (context, state) {
            final target = switch (state) {
              AsyncSuccess<IssuesData>(:final data) => data.target,
              _ => null,
            };
            if (target == null) return const SizedBox.shrink();
            return FloatingActionButton(
              backgroundColor: AppColors.red400,
              shape: const CircleBorder(),
              onPressed: () => NewIssueSheet.show(context, target),
              child: AppIcon.plus(size: 26),
            );
          },
        ),
      ),
      builder: (context, data) {
        final target = data.target;
        final issues = data.issues;
        final filtered = issues.where((i) => i.status == _selected).toList();

        return BlocListener<IssuesBloc, IssuesState>(
          listenWhen: (previous, current) =>
              current is AsyncSuccess<IssuesData> &&
              current.data.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    (state as AsyncSuccess<IssuesData>).data.errorMessage!,
                  ),
                ),
              );
          },
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IssuesHeader(projectLabel: target?.label ?? '연결된 저장소 없음'),
                if (target == null)
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.s16),
                        child: CoworkEmptyState(
                          icon: Icons.link_off,
                          title: '연결된 저장소가 없어요',
                          description: '프로젝트에 GitHub 저장소를 연결하면 이슈를 볼 수 있어요.',
                        ),
                      ),
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                    ),
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
                    child: RefreshIndicator(
                      onRefresh: () {
                        final done = Completer<void>();
                        context.read<IssuesBloc>().add(
                          IssuesEvent.refreshed(done: done),
                        );
                        return done.future;
                      },
                      child: filtered.isEmpty
                          ? ListView(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(AppSpacing.s16),
                                  child: CoworkEmptyState(
                                    icon: Icons.view_kanban_outlined,
                                    title: '${_selected.label} 이슈가 없어요',
                                    description: '새 이슈를 만들어 시작해보세요.',
                                  ),
                                ),
                              ],
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
                                  extra: IssueDetailArgs(
                                    issue: filtered[index],
                                    target: target,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
