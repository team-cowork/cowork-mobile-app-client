import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/profile.dart';

/// GitHub 커밋 스트릭 카드.
class GithubStreakCard extends StatelessWidget {
  const GithubStreakCard({super.key, required this.streak});

  final GithubStreak streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        18,
        AppSpacing.s20,
        AppSpacing.s20,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        border: Border.all(color: AppColors.neutral700),
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GitHub 커밋 스트릭',
                style: AppFont.labelS.copyWith(color: AppColors.darkOnSurface),
              ),
              Text(
                streak.rangeLabel,
                style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.neutral850,
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: streak.notice == null
                ? _Heatmap(commitsByDay: streak.commitsByDay)
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s20,
                    ),
                    child: Text(
                      streak.notice!,
                      textAlign: TextAlign.center,
                      style: AppFont.subtextS.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 주 단위 커밋 히트맵. 왼쪽이 가장 오래된 주, 오른쪽 끝이 이번 주다.
///
/// 세로 한 칸이 하루(일~토), 가로 한 칸이 한 주. 셀은 열 너비를 따라가는 정사각형이라
/// 화면 폭이 달라져도 비율이 유지된다.
class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.commitsByDay});

  final Map<DateTime, int> commitsByDay;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // 이번 주 일요일에서 (weeks - 1) 주를 되감은 날이 왼쪽 위 첫 칸이다.
    final start = today.subtract(
      Duration(days: today.weekday % 7 + (GithubStreak.weeks - 1) * 7),
    );

    return Row(
      spacing: 3,
      children: [
        for (var week = 0; week < GithubStreak.weeks; week++)
          Expanded(
            child: Column(
              spacing: 3,
              children: [
                for (var day = 0; day < 7; day++)
                  _cell(start.add(Duration(days: week * 7 + day)), today),
              ],
            ),
          ),
      ],
    );
  }

  /// 하루 칸. 아직 오지 않은 날은 자리만 비워 둔다.
  Widget _cell(DateTime day, DateTime today) => AspectRatio(
    aspectRatio: 1,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: day.isAfter(today)
            ? Colors.transparent
            : _colorOf(commitsByDay[day] ?? 0),
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
    ),
  );

  /// 커밋 수 구간별 색. GitHub 잔디와 같은 4단계다.
  static Color _colorOf(int commits) => switch (commits) {
    0 => AppColors.neutral750,
    <= 2 => AppColors.green900,
    <= 5 => AppColors.green600,
    <= 9 => AppColors.green400,
    _ => AppColors.green300,
  };
}
