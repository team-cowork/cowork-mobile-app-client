import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../viewModels/members_bloc.dart';
import '../widgets/channel_member_tile.dart';
import '../widgets/members_header.dart';

class MembersView extends StatelessWidget {
  const MembersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<MembersBloc, ChannelMembersData>(
      create: (_) => MembersBloc()..add(const MembersRequested()),
      errorTitle: '멤버를 불러오지 못했어요',
      onRetry: (context) =>
          context.read<MembersBloc>().add(const MembersRequested()),
      builder: (context, data) {
        final online = data.members.where((m) => m.isOnline).toList();
        final offline = data.members.where((m) => !m.isOnline).toList();

        return SafeArea(
          child: Column(
            children: [
              MembersHeader(
                channelName: data.channelName,
                memberCount: data.members.length,
                onBack: () => context.pop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                  ),
                  children: [
                    if (online.isNotEmpty) ...[
                      _SectionLabel('온라인 — ${online.length}'),
                      for (final member in online)
                        ChannelMemberTile(member: member),
                    ],
                    if (offline.isNotEmpty) ...[
                      _SectionLabel('오프라인 — ${offline.length}'),
                      for (final member in offline)
                        ChannelMemberTile(member: member),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
        AppSpacing.s4,
        AppSpacing.s10,
        AppSpacing.s4,
        AppSpacing.s6,
      ),
      child: Text(
        label,
        style: AppFont.labelXs.copyWith(color: AppColors.neutral300),
      ),
    );
  }
}
