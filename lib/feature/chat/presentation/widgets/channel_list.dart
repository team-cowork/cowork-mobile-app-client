import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/channel.dart';
import '../../domain/enums/channel_type.dart';
import 'channel_group_header.dart';
import 'channel_group_item.dart';

class ChannelList extends StatelessWidget {
  const ChannelList({super.key, required this.channelGroups});

  final List<ChannelGroup> channelGroups;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      child: SingleChildScrollView(
        child: Column(
          spacing: AppSpacing.s4,
          children: [
            for (final group in channelGroups) ...[
              ChannelGroupHeader(label: group.name),
              for (final channel in group.channels)
                ChannelGroupItem.type(
                  type: channel.type,
                  label: channel.name,
                  onTap: channel.type == ChannelType.chat
                      ? () => context.push('/chat/channel')
                      : null,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
