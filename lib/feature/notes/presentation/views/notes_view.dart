import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../viewModels/notes_bloc.dart';
import '../widgets/note_card.dart';

/// 회의록 목록 화면.
///
/// Figma `App / Notes (회의록)` 스펙에 맞춘 다크 전용 레이아웃.
class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotesBloc()..add(const NotesRequested()),
      child: Scaffold(
        backgroundColor: AppColors.neutral850,
        body: SafeArea(
          child: Column(
            children: [
              const _NotesHeader(),
              Expanded(
                child: BlocBuilder<NotesBloc, NotesState>(
                  builder: (context, state) {
                    return switch (state) {
                      NotesFailure() => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          child: CoworkErrorState(
                            title: '회의록을 불러오지 못했어요',
                            description: '잠시 후 다시 시도해 주세요.',
                            retryLabel: '다시 시도',
                            onRetry: () => context
                                .read<NotesBloc>()
                                .add(const NotesRequested()),
                          ),
                        ),
                      ),
                      NotesSuccess(:final notes) => ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s16,
                          AppSpacing.s4,
                          AppSpacing.s16,
                          AppSpacing.s16,
                        ),
                        itemCount: notes.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.s10),
                        itemBuilder: (_, i) => NoteCard(note: notes[i]),
                      ),
                      _ => const Center(child: CoworkLoadingPane()),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar:
            const _NotesTabBar(), // TODO: 하단 탭 바를 BottomNavigationBar로 변경하고, 탭 전환 시 라우팅 로직 추가
      ),
    );
  }
}

/// 제목 + 부제 + `새 노트` 버튼으로 구성된 상단 헤더.
class _NotesHeader extends StatelessWidget {
  const _NotesHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s6,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '회의록',
                style: AppFont.titleM.copyWith(color: AppColors.darkOnSurface),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                '회의 기록 · 템플릿 기반 작성',
                style: AppFont.subtextM.copyWith(color: AppColors.neutral300),
              ),
            ],
          ),
          const _NewNoteButton(),
        ],
      ),
    );
  }
}

/// `+ 새 노트` 강조 버튼. (동작은 추후 연결)
class _NewNoteButton extends StatelessWidget {
  const _NewNoteButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // TODO: 새 노트 작성 화면 연결
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.red400,
          borderRadius: BorderRadius.circular(AppRadius.r10),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s12,
          AppSpacing.s8,
          AppSpacing.s14,
          AppSpacing.s8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 16, color: AppColors.white),
            const SizedBox(width: AppSpacing.s4),
            Text(
              '새 노트',
              style: AppFont.subtextM.copyWith(
                fontWeight: AppFont.semiBold,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 하단 탭 바 (회의록 선택 상태).
class _NotesTabBar extends StatelessWidget {
  const _NotesTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.neutral800,
        border: Border(top: BorderSide(color: AppColors.neutral700)),
      ),
      padding: const EdgeInsets.only(
        top: AppSpacing.s8,
        bottom: AppSpacing.s20,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const _TabItem(icon: Icons.forum_outlined, label: '채널'),
            const _TabItem(icon: Icons.view_kanban_outlined, label: '이슈'),
            const _TabItem(
              icon: Icons.description_outlined,
              label: '회의록',
              selected: true,
            ),
            _TabItem(
              icon: Icons.person_outline,
              label: '프로필',
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.red400 : AppColors.neutral300;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: AppSpacing.s4),
              Text(
                label,
                style: AppFont.subtextS.copyWith(
                  fontWeight: selected ? AppFont.semiBold : AppFont.regular,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
