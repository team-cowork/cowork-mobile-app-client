import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/base_scaffold.dart';
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
      child: BaseScaffold(
        appBar: CoworkAppBar.section(
          title: '회의록',
          subtitle: '회의 기록 · 템플릿 기반 작성',
          actions: const [_NewNoteButton()],
        ),
        body: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            return switch (state) {
              NotesFailure() => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: CoworkErrorState(
                    title: '회의록을 불러오지 못했어요',
                    description: '잠시 후 다시 시도해 주세요.',
                    retryLabel: '다시 시도',
                    onRetry: () =>
                        context.read<NotesBloc>().add(const NotesRequested()),
                  ),
                ),
              ),
              NotesSuccess(:final notes) when notes.isEmpty => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.s16),
                  child: CoworkEmptyState(
                    icon: Icons.description_outlined,
                    title: '아직 회의록이 없어요',
                    description: '첫 회의록을 작성해 팀 기록을 남겨보세요.',
                  ),
                ),
              ),
              NotesSuccess(:final notes) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s12,
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
