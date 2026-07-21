import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/channel_type.dart';

/// 채널 그룹 안의 개별 항목(아이콘 + 이름).
///
/// 채널뿐 아니라 데일리스크럼, 깃허브 웹훅처럼 아이콘과 탭 동작만 다른
/// 항목에도 공용으로 쓴다. [onTap]이 있으면 눌리는 행, 없으면 정적인 행이 된다.
class ChannelGroupItem extends StatelessWidget {
  const ChannelGroupItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  /// [type]에 맞는 기본 아이콘으로 [ChannelGroupItem]을 만든다.
  factory ChannelGroupItem.type({
    Key? key,
    required ChannelType type,
    required String label,
    VoidCallback? onTap,
  }) {
    return ChannelGroupItem(
      key: key,
      icon: _iconFor(type),
      label: label,
      onTap: onTap,
    );
  }

  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  static Widget _iconFor(ChannelType type) => switch (type) {
    ChannelType.chat => AppIcon.channelChat(),
    ChannelType.webhook => AppIcon.webhook(),
    ChannelType.file => const Icon(
      Icons.insert_drive_file_outlined,
      size: AppSize.iconSmall,
      color: AppColors.neutral300,
    ),
    ChannelType.accountShare => const Icon(
      Icons.key,
      size: AppSize.iconSmall,
      color: AppColors.neutral300,
    ),
    ChannelType.meetingNote => const Icon(
      AppIcon.navNote,
      size: AppSize.iconSmall,
      color: AppColors.neutral300,
    ),
    ChannelType.voice => AppIcon.speaker(),
  };

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: AppSpacing.s12,
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: AppSpacing.s10),
          Text(
            label,
            style: AppFont.subtextL.copyWith(color: AppColors.neutral300),
          ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
