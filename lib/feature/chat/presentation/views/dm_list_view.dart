import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../viewModels/dm_list_bloc.dart';
import '../widgets/dm_list_header.dart';
import '../widgets/dm_list_tile.dart';
import '../widgets/dm_online_strip.dart';

class DmListView extends StatelessWidget {
  const DmListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<DmListBloc, DmListData>(
      create: (_) => DmListBloc()..add(const DmListRequested()),
      errorTitle: 'DM 목록을 불러오지 못했어요',
      onRetry: (context) => context.read<DmListBloc>().add(const DmListRequested()),
      builder: (context, data) => SafeArea(
        child: Column(
          children: [
            const DmListHeader(),
            DmOnlineStrip(entries: data.onlineStrip),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
                children: [
                  if (data.pinned.isNotEmpty) ...[
                    const _SectionLabel('고정됨'),
                    for (final preview in data.pinned)
                      DmListTile(preview: preview),
                  ],
                  if (data.recent.isNotEmpty) ...[
                    const _SectionLabel('최근'),
                    for (final preview in data.recent)
                      DmListTile(preview: preview),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s12,
        AppSpacing.s12,
        AppSpacing.s4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.s4,
        children: [
          AppIcon.dropDown(size: 12),
          Text(
            label,
            style: AppFont.subtextS.copyWith(
              fontWeight: AppFont.semiBold,
              color: AppColors.neutral300,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
