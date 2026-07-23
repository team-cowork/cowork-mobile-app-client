import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/utils/base_scaffold.dart';
import '../../../profile/data/profile_store.dart';
import '../../domain/note.dart';
import 'note_edit_view.dart';

/// 회의록 상세 화면.
///
/// Figma `App / Note Detail (회의록)` 스펙에 맞춘 다크 전용 레이아웃.
/// 제목·작성자·참여자·배지 헤더와 안건 / 결정 사항 / 액션 아이템 섹션으로 구성된다.
class NoteDetailView extends StatefulWidget {
  const NoteDetailView({super.key, required this.note});

  final Note note;

  /// 아바타 색상 팔레트. 작성자는 0번, 참여자는 1번부터 순서대로 사용한다.
  static const _avatarColors = [
    AppColors.blue500,
    AppColors.green500,
    AppColors.amber500,
    AppColors.red400,
  ];

  static Color _avatarColor(int index) =>
      _avatarColors[index % _avatarColors.length];

  @override
  State<NoteDetailView> createState() => _NoteDetailViewState();
}

class _NoteDetailViewState extends State<NoteDetailView> {
  late Note _note = widget.note;

  /// 내가 작성한 회의록일 때만 편집을 허용한다.
  bool get _isMine =>
      _note.author.authorId == ProfileStore.instance.currentUserId;

  Future<void> _openEditor() async {
    final updated = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (_) => NoteEditView(note: _note)),
    );
    if (updated != null) setState(() => _note = updated);
  }

  @override
  Widget build(BuildContext context) {
    final note = _note;
    return BaseScaffold(
      appBar: CoworkAppBar.detail(
        // 상세 화면 제목은 본문 상단에 크게 노출되므로 앱바는 액션만 둔다.
        title: '',
        actions: [
          CoworkIconButton(
            icon: Icons.share_outlined,
            size: CoworkIconButtonSize.small,
            variant: CoworkIconButtonVariant.ghost,
            color: CoworkIconButtonColor.neutral,
            semanticLabel: '공유',
            onPressed: () {},
          ),
          if (_isMine)
            CoworkIconButton(
              icon: Icons.edit_outlined,
              size: CoworkIconButtonSize.small,
              variant: CoworkIconButtonVariant.ghost,
              color: CoworkIconButtonColor.neutral,
              semanticLabel: '편집',
              onPressed: _openEditor,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s6,
          AppSpacing.s20,
          AppSpacing.s24,
        ),
        children: [
          Text(
            note.title,
            style: AppFont.titleM.copyWith(
              height: 1.32,
              color: AppColors.darkOnSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.s14),
          _AuthorLine(note: note),
          const SizedBox(height: AppSpacing.s14),
          if (note.tags.isNotEmpty) ...[
            Wrap(
              spacing: AppSpacing.s6,
              runSpacing: AppSpacing.s6,
              children: [for (final tag in note.tags) _tagBadge(tag)],
            ),
            const SizedBox(height: AppSpacing.s14),
          ],
          const Divider(height: 1, thickness: 1, color: AppColors.neutral700),
          if (note.summary.isNotEmpty)
            _Section(title: '내용', lines: [note.summary]),
          if (note.agenda.isNotEmpty)
            _Section(title: '안건', lines: note.agenda),
          if (note.decisions.isNotEmpty)
            _Section(title: '결정 사항', lines: note.decisions),
          if (note.actionItems.isNotEmpty) ...[
            const _SectionTitle('액션 아이템'),
            for (final item in note.actionItems) _ActionItemRow(item: item),
          ],
        ],
      ),
    );
  }

  /// `확정` 처럼 상태를 뜻하는 태그는 점 배지로, 나머지는 일반 배지로 표시한다.
  Widget _tagBadge(String tag) => tag == '확정'
      ? CoworkStatusBadge(label: tag, status: CoworkStatusBadgeStatus.done)
      : CoworkBadge(label: tag);
}

/// 작성자 아바타 + `이름 · 날짜`, 우측에 참여자 아바타 스택.
class _AuthorLine extends StatelessWidget {
  const _AuthorLine({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(
          initial: note.author.initial,
          color: NoteDetailView._avatarColor(0),
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(
          note.author.name,
          style: AppFont.labelXs.copyWith(color: AppColors.darkOnSurface),
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(
          '· ${note.author.date}',
          style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
        ),
        const Spacer(),
        if (note.participants.isNotEmpty) _ParticipantStack(note.participants),
      ],
    );
  }
}

/// 참여자 아바타를 8px 씩 겹쳐 쌓는다.
///
/// 최대 [_maxVisible]개까지만 노출하고, 초과하면 마지막 칸을 `+N` 카운터로 대체한다.
/// 탭하면 전체 참여자 목록 시트를 띄운다.
class _ParticipantStack extends StatelessWidget {
  const _ParticipantStack(this.initials);

  final List<String> initials;

  static const _size = 24.0;
  static const _step = 16.0;
  static const _maxVisible = 5;

  @override
  Widget build(BuildContext context) {
    if (initials.isEmpty) return const SizedBox.shrink();

    final overflow = initials.length > _maxVisible;
    // 넘치면 마지막 한 칸을 +N 카운터로 쓰므로 아바타는 4개만 보인다.
    final avatarCount = overflow ? _maxVisible - 1 : initials.length;
    final slots = overflow ? _maxVisible : initials.length;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showParticipants(context, initials),
      child: SizedBox(
        width: _size + _step * (slots - 1),
        height: _size,
        child: Stack(
          children: [
            for (var i = 0; i < avatarCount; i++)
              Positioned(
                left: i * _step,
                child: _Avatar(
                  initial: initials[i],
                  // 작성자가 0번을 쓰므로 참여자는 1번부터.
                  color: NoteDetailView._avatarColor(i + 1),
                  bordered: true,
                ),
              ),
            if (overflow)
              Positioned(
                left: avatarCount * _step,
                child: _Avatar(
                  initial: '+${initials.length - avatarCount}',
                  color: AppColors.neutral600,
                  bordered: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 참여자 전체 목록을 바텀시트로 띄운다.
Future<void> _showParticipants(BuildContext context, List<String> initials) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.neutral800,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s12,
          AppSpacing.s20,
          AppSpacing.s16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              '참여자 ${initials.length}명',
              style: AppFont.labelS.copyWith(color: AppColors.darkOnSurface),
            ),
            const SizedBox(height: AppSpacing.s12),
            for (final (index, initial) in initials.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
                child: Row(
                  children: [
                    _Avatar(
                      initial: initial,
                      color: NoteDetailView._avatarColor(index + 1),
                    ),
                    const SizedBox(width: AppSpacing.s10),
                    Text(
                      initial,
                      style: AppFont.subtextM.copyWith(
                        fontSize: 14,
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// 이니셜 한 글자를 담는 원형 아바타.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initial,
    required this.color,
    this.bordered = false,
  });

  final String initial;
  final Color color;

  /// 겹쳐 쌓을 때 배경색으로 테두리를 둘러 경계를 만든다.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: bordered
            ? Border.all(color: AppColors.neutral850, width: 2)
            : null,
      ),
      child: Text(
        initial,
        style: AppFont.labelXs.copyWith(fontSize: 10, color: AppColors.white),
      ),
    );
  }
}

/// 섹션 본문 마크다운 렌더 스타일. 다크 테마 본문 톤에 맞춘다.
final _markdownBodyStyle = AppFont.subtextM.copyWith(
  fontSize: 14,
  height: 1.5,
  color: AppColors.darkOnSurface.withValues(alpha: 0.9),
);

final _markdownStyle = MarkdownStyleSheet(
  p: _markdownBodyStyle,
  listBullet: _markdownBodyStyle,
  strong: _markdownBodyStyle.copyWith(fontWeight: AppFont.bold),
  h1: _markdownBodyStyle.copyWith(fontSize: 18, fontWeight: AppFont.bold),
  h2: _markdownBodyStyle.copyWith(fontSize: 16, fontWeight: AppFont.bold),
  h3: _markdownBodyStyle.copyWith(fontSize: 15, fontWeight: AppFont.bold),
  a: _markdownBodyStyle.copyWith(color: AppColors.red400),
);

/// `안건`, `결정 사항` 처럼 제목 + 여러 줄 본문으로 이뤄진 섹션.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title),
        MarkdownBody(
          data: lines.join('\n'),
          shrinkWrap: true,
          styleSheet: _markdownStyle,
        ),
      ],
    );
  }
}

/// 섹션 제목 (안건 / 결정 사항 / 액션 아이템).
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.s14,
        bottom: AppSpacing.s14,
      ),
      child: Text(
        title,
        style: AppFont.labelXs.copyWith(
          fontWeight: AppFont.bold,
          letterSpacing: 0.4,
          color: AppColors.neutral300,
        ),
      ),
    );
  }
}

/// 액션 아이템 체크박스 한 줄.
///
// ponytail: 체크 상태는 화면 안에서만 유지된다. 서버 연동 시 Bloc 이벤트로 승격.
class _ActionItemRow extends StatefulWidget {
  const _ActionItemRow({required this.item});

  final NoteActionItem item;

  @override
  State<_ActionItemRow> createState() => _ActionItemRowState();
}

class _ActionItemRowState extends State<_ActionItemRow> {
  late bool _done = widget.item.done;

  @override
  void didUpdateWidget(covariant _ActionItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 목록이 갱신되어 같은 자리에 다른 item 이 오면 체크 상태를 새 값으로 맞춘다.
    if (oldWidget.item != widget.item) {
      _done = widget.item.done;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _done = !_done),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _done ? AppColors.red400 : AppColors.neutral750,
                border: Border.all(
                  color: _done ? AppColors.red400 : AppColors.neutral300,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppRadius.r6),
              ),
              child: _done
                  ? const Icon(Icons.check, size: 13, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: Text(
                widget.item.label,
                style: AppFont.subtextM.copyWith(
                  fontSize: 14,
                  color: _done
                      ? AppColors.neutral300
                      : AppColors.darkOnSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
