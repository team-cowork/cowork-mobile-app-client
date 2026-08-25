import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/dm_presence_entry.dart';
import 'chat_color_mapping.dart';

class DmOnlineStrip extends StatelessWidget {
  const DmOnlineStrip({required this.entries, this.onAddTap, super.key});

  final List<DmPresenceEntry> entries;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s4,
        AppSpacing.s16,
        AppSpacing.s14,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: AppSpacing.s14,
          children: [
            for (final entry in entries)
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  children: [
                    CoworkAvatar(
                      initials: entry.profile.avatarInitial,
                      size: 52,
                      backgroundColor: entry.avatarColor.toColor(),
                      foregroundColor: AppColors.white,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: entry.presence.toColor(),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neutral850,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            GestureDetector(
              onTap: onAddTap,
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.neutral750,
                  shape: BoxShape.circle,
                ),
                child: AppIcon.plus(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
