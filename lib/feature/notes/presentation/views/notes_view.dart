import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/command_bloc.dart';
import '../../../../shared/widgets/bloc_scaffold.dart';
import '../../../../shared/widgets/create_sheet.dart';
import '../../data/notes_repository.dart';
import '../../domain/note.dart';
import '../blocs/notes/notes_bloc.dart';

/// 회의록 목록 화면.
///
/// Figma `App / Notes (회의록)` 스펙에 맞춘 다크 전용 레이아웃.
class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<NotesBloc, List<Note>>(
      create: (context) =>
          NotesBloc(context.read<NotesRepository>())
            ..add(const NotesRequested()),
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
          itemBuilder: (_, i) => _NoteCard(note: notes[i]),
        );
      },
    );
  }
}

/// `+ 새 노트` 강조 버튼. 시트에서 회의록을 쓰면 목록을 다시 읽고 알린다.
class _NewNoteButton extends StatelessWidget {
  const _NewNoteButton();

  /// 작성자·작성일은 서버가 채우므로 쓴 회의록을 끼워 넣지 않고 목록째 다시 읽는다.
  static Future<void> _createNote(BuildContext context) async {
    final bloc = context.read<NotesBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final created = await _NewNoteSheet.show(context);
    if (created != true) return;
    bloc.add(const NotesRequested());
    messenger.showSnackBar(const SnackBar(content: Text('회의록을 만들었어요.')));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _createNote(context),
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

/// 회의록 목록의 카드 한 장.
///
/// 제목 + 태그 배지 / 요약 / 작성자·날짜로 구성된다.
/// Figma `App / Notes (회의록)` 스펙에 맞춘 다크 전용 레이아웃.
class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 상세에서 편집하면 서버 회의록이 바뀌므로, 돌아오면 목록을 다시 불러온다.
      onTap: () async {
        await context.push<void>('/notes/detail', extra: note);
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

/// 새 회의록 입력값.
typedef _NewNote = ({String title, String summary});

/// 회의록 작성 요청 하나를 실행하는 [CommandBloc].
typedef _CreateNote = CommandBloc<_NewNote, void>;

/// 회의록 생성(새 노트) 바텀시트.
///
/// Figma `Sheet / 새 노트` 스펙. 제목·내용 입력과 템플릿 선택을 제공한다. 채널·팀
/// 시트처럼 쓰는 동안은 입력과 닫기를 잠그고, 실패하면 입력값을 둔 채 사유를
/// 보여준다. 성공하면 true 를 돌려주며 닫힌다.
///
/// ponytail: 입력값은 시트가 닫히면 버려지는 화면 로컬 상태라 setState 로 들고,
/// 서버 요청 상태만 [CommandBloc] 이 맡는다. 작성 중·실패를 [NotesBloc] 에 실으면
/// 목록 전체가 로딩·오류 화면으로 바뀌고 시트 입력값도 사라진다.
class _NewNoteSheet extends StatefulWidget {
  const _NewNoteSheet();

  /// 시트를 띄우고 회의록을 썼는지 돌려준다. 쓰지 않고 닫으면 null.
  static Future<bool?> show(BuildContext context) {
    final repository = context.read<NotesRepository>();
    return CreateSheet.show<bool>(
      context,
      (_) => BlocProvider(
        create: (_) => _CreateNote(
          (note) =>
              repository.createNote(title: note.title, summary: note.summary),
          tag: 'Notes',
        ),
        child: const _NewNoteSheet(),
      ),
    );
  }

  // ponytail: 서버 템플릿(`/channels/{id}/meeting-note-templates`)과 이어져 있지
  // 않다. 지금은 채널에 켜져 있는 템플릿으로 저장된다. 채널을 고를 수 있게 되면
  // 이 목록을 서버 템플릿으로 갈아끼운다.
  static const templates = [
    (label: '자유 양식', description: '빈 문서로 시작'),
    (label: '회의록', description: '안건 · 결정 · 액션 아이템'),
    (label: '스프린트 회고', description: 'Keep · Problem · Try'),
  ];

  @override
  State<_NewNoteSheet> createState() => _NewNoteSheetState();
}

class _NewNoteSheetState extends State<_NewNoteSheet> {
  String _title = '';
  String _content = '';
  int _template = 0;

  /// 제목이 있어야 노트를 만들 수 있다.
  bool get _canSubmit => _title.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<_CreateNote, AsyncState<void>>(
      listener: (context, state) {
        if (state is AsyncSuccess) Navigator.of(context).pop(true);
      },
      builder: (context, state) {
        // 성공 직후 닫히기 전 한 프레임도 잠가 둔다.
        final submitting = state is AsyncLoading || state is AsyncSuccess;

        return CreateSheet(
          title: '새 노트',
          dismissible: !submitting,
          children: [
            CoworkTextField(
              labelText: '제목',
              hintText: '노트 제목을 입력하세요',
              enabled: !submitting,
              textInputAction: TextInputAction.next,
              onChanged: (value) => setState(() => _title = value),
            ),
            CoworkTextArea(
              labelText: '내용',
              hintText: '회의 안건과 논의 내용을 적어보세요. 편집 화면에서 이어서 작성할 수 있어요.',
              minLines: 4,
              enabled: !submitting,
              onChanged: (value) => setState(() => _content = value),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s8,
              children: [
                Text(
                  '템플릿',
                  style: AppFont.subtextS.copyWith(
                    fontWeight: AppFont.semiBold,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                for (final (index, template) in _NewNoteSheet.templates.indexed)
                  CoworkOptionCard(
                    label: template.label,
                    description: template.description,
                    icon: AppIcon.navNote,
                    selected: index == _template,
                    onTap: submitting
                        ? null
                        : () => setState(() => _template = index),
                    trailing: _TemplateRadio(selected: index == _template),
                  ),
              ],
            ),
            if (state case AsyncFailure(:final message))
              CreateSheetError(
                title: '노트를 만들지 못했어요',
                message: message ?? '잠시 후 다시 시도해 주세요.',
              ),
            SizedBox(
              width: double.infinity,
              child: CoworkButton(
                label: submitting ? '노트 생성 중…' : '노트 만들기',
                size: CoworkButtonSize.large,
                enabled: _canSubmit && !submitting,
                onPressed: () => context.read<_CreateNote>().add(
                  CommandEvent.run((
                    title: _title.trim(),
                    summary: _content.trim(),
                  )),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 템플릿 카드 오른쪽의 라디오 표시.
class _TemplateRadio extends StatelessWidget {
  const _TemplateRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.primary : colors.onSurfaceVariant,
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary,
              ),
            )
          : null,
    );
  }
}
