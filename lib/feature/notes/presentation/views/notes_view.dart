import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../domain/note.dart';
import '../blocs/notes/notes_bloc.dart';
import '../widgets/new_note_sheet.dart';
import '../widgets/note_card.dart';

/// 회의록 목록 화면.
///
/// Figma `App / Notes (회의록)` 스펙에 맞춘 다크 전용 레이아웃.
class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<NotesBloc, List<Note>>(
      create: (_) => NotesBloc()..add(const NotesRequested()),
      errorTitle: '회의록을 불러오지 못했어요',
      onRetry: (context) =>
          context.read<NotesBloc>().add(const NotesRequested()),
      appBar: CoworkAppBar.section(
        title: '회의록',
        subtitle: '회의 기록 · 템플릿 기반 작성',
        actions: const [_NewNoteButton()],
      ),
      builder: (context, notes) {
        if (notes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s16),
              child: CoworkEmptyState(
                icon: Icons.description_outlined,
                title: '아직 회의록이 없어요',
                description: '첫 회의록을 작성해 팀 기록을 남겨보세요.',
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s12,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          itemCount: notes.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s10),
          itemBuilder: (_, i) => NoteCard(note: notes[i]),
        );
      },
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
      onTap: () => NewNoteSheet.show(context),
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
