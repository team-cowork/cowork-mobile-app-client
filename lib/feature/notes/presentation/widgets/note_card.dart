import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/note.dart';
import '../blocs/notes/notes_bloc.dart';
import '../views/note_detail_view.dart';

/// 회의록 목록의 카드 한 장.
///
/// 제목 + 태그 배지 / 요약 / 작성자·날짜로 구성된다.
/// Figma `App / Notes (회의록)` 스펙에 맞춘 다크 전용 레이아웃.
class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 상세에서 편집하면 스토어가 갱신되므로, 돌아오면 목록을 다시 불러온다.
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => NoteDetailView(note: note)),
        );
        if (context.mounted) {
          context.read<NotesBloc>().add(const NotesRequested());
        }
      },
      child: _card(),
    );
  }

  Widget _card() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        border: Border.all(color: AppColors.neutral700),
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s8,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: AppFont.labelS.copyWith(
                    fontSize: 16,
                    color: AppColors.darkOnSurface,
                  ),
                ),
              ),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.s8),
                Wrap(
                  spacing: AppSpacing.s4,
                  children: [
                    for (final tag in note.tags) CoworkBadge(label: tag),
                  ],
                ),
              ],
            ],
          ),
          Text(
            note.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFont.subtextM.copyWith(
              height: 1.45,
              color: AppColors.neutral300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s4),
            child: _AuthorLine(author: note.author),
          ),
        ],
      ),
    );
  }
}

/// 작성자 아바타(이니셜) + `이름 · 날짜` 라인.
class _AuthorLine extends StatelessWidget {
  const _AuthorLine({required this.author});

  final NoteAuthor author;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColors.neutral600,
            shape: BoxShape.circle,
          ),
          child: author.avatarUrl.isEmpty
              ? _initialFallback()
              : Image.network(
                  author.avatarUrl,
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _initialFallback(),
                ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(
          '${author.name}  ·  ${author.date}',
          style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
        ),
      ],
    );
  }

  Widget _initialFallback() => Text(
    author.initial,
    style: AppFont.labelXs.copyWith(fontSize: 9, color: AppColors.white),
  );
}
