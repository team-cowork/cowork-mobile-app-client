import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/base_scaffold.dart';
import '../../domain/note.dart';
import '../viewModels/note_edit_bloc.dart';

/// 회의록 편집 화면.
///
/// Figma `App / 노트 편집 (회의록)`(node 1312-3420) 스펙에 맞춘 다크 전용 레이아웃.
/// 제목과 안건 / 결정 사항 / 액션 아이템 섹션을 마크다운 텍스트로 편집하고,
/// 하단 서식 툴바로 포커스된 입력창에 마크다운을 삽입한다.
class NoteEditView extends StatelessWidget {
  const NoteEditView({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoteEditBloc(note),
      child: BlocListener<NoteEditBloc, NoteEditState>(
        // 저장이 끝나면 갱신된 노트를 들고 상세 화면으로 돌아간다.
        listenWhen: (previous, current) => current.saved,
        listener: (context, state) => Navigator.of(context).pop(state.note),
        child: _NoteEditForm(note: note),
      ),
    );
  }
}

/// 편집 폼. 컨트롤러·포커스 등 화면 상태를 들고, 저장은 [NoteEditBloc]에 위임한다.
class _NoteEditForm extends StatefulWidget {
  const _NoteEditForm({required this.note});

  final Note note;

  @override
  State<_NoteEditForm> createState() => _NoteEditFormState();
}

class _NoteEditFormState extends State<_NoteEditForm> {
  late final _title = TextEditingController(text: widget.note.title);
  late final _summary = TextEditingController(text: widget.note.summary);
  late final _agenda = TextEditingController(
    text: widget.note.agenda.join('\n'),
  );
  late final _decisions = TextEditingController(
    text: widget.note.decisions.join('\n'),
  );
  late final _actions = TextEditingController(
    text: _actionItemsToMarkdown(widget.note.actionItems),
  );

  final _summaryFocus = FocusNode();
  final _agendaFocus = FocusNode();
  final _decisionsFocus = FocusNode();
  final _actionsFocus = FocusNode();

  /// 툴바 삽입 대상: 마지막으로 포커스됐던 섹션과 그때의 선택 영역.
  ///
  /// 툴바 버튼을 누르면 입력창이 blur 되면서 `controller.selection` 이 무효화되므로,
  /// 포커스가 살아 있는 동안 유효한 선택을 캐시해 둔다. 기본값은 안건(맨 위 섹션).
  late TextEditingController _active = _agenda;
  late FocusNode _activeFocus = _agendaFocus;
  TextSelection _activeSelection = const TextSelection.collapsed(offset: 0);

  @override
  void initState() {
    super.initState();
    _bind(_summary, _summaryFocus);
    _bind(_agenda, _agendaFocus);
    _bind(_decisions, _decisionsFocus);
    _bind(_actions, _actionsFocus);
  }

  void _bind(TextEditingController controller, FocusNode focus) {
    void cache() {
      if (!focus.hasFocus) return;
      _active = controller;
      _activeFocus = focus;
      if (controller.selection.isValid) _activeSelection = controller.selection;
    }

    focus.addListener(cache);
    controller.addListener(cache);
  }

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _agenda.dispose();
    _decisions.dispose();
    _actions.dispose();
    _summaryFocus.dispose();
    _agendaFocus.dispose();
    _decisionsFocus.dispose();
    _actionsFocus.dispose();
    super.dispose();
  }

  /// 툴바 버튼: 마지막으로 포커스된 섹션에 마크다운 서식을 삽입한다.
  void _applyMarkdown(MarkdownAction action) {
    final controller = _active;
    final selection = _activeSelection.isValid
        ? _activeSelection
        : TextSelection.collapsed(offset: controller.text.length);
    final result = applyMarkdown(controller.text, selection, action);
    controller.value = TextEditingValue(
      text: result.text,
      selection: result.selection,
    );
    _activeSelection = result.selection;
    // 포커스가 풀려 있으면 편집을 이어갈 수 있도록 되돌린다.
    _activeFocus.requestFocus();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해 주세요.')));
      return;
    }
    context.read<NoteEditBloc>().add(
      NoteEditSaved(
        title: title,
        summary: _summary.text.trim(),
        agenda: _splitLines(_agenda.text),
        decisions: _splitLines(_decisions.text),
        actionItems: parseActionItems(_actions.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CoworkAppBar.detail(
        title: '📝 회의록',
        actions: [CoworkButton(label: '저장', onPressed: _save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s6,
          AppSpacing.s20,
          AppSpacing.s24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _title,
              style: AppFont.titleM.copyWith(
                height: 1.32,
                color: AppColors.darkOnSurface,
              ),
              cursorColor: AppColors.red400,
              maxLines: null,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '제목을 입력하세요',
                hintStyle: TextStyle(color: AppColors.neutral500),
              ),
            ),
            const SizedBox(height: AppSpacing.s14),
            _MetaLine(author: widget.note.author),
            const SizedBox(height: AppSpacing.s14),
            const Divider(height: 1, thickness: 1, color: AppColors.neutral700),
            const SizedBox(height: AppSpacing.s14),
            _EditSection(
              title: '내용',
              controller: _summary,
              focusNode: _summaryFocus,
              hintText: '회의 내용을 입력하세요',
            ),
            const SizedBox(height: AppSpacing.s20),
            _EditSection(
              title: '안건',
              controller: _agenda,
              focusNode: _agendaFocus,
              hintText: '이번 회의의 안건을 입력하세요',
            ),
            const SizedBox(height: AppSpacing.s20),
            _EditSection(
              title: '결정 사항',
              controller: _decisions,
              focusNode: _decisionsFocus,
              hintText: '이번 회의에서 결정된 내용을 입력하세요',
            ),
            const SizedBox(height: AppSpacing.s20),
            _EditSection(
              title: '액션 아이템',
              controller: _actions,
              focusNode: _actionsFocus,
              hintText: '- [ ] 담당자와 마감일을 지정하세요',
            ),
          ],
        ),
      ),
      bottomNavigationBar: _EditorToolbar(onAction: _applyMarkdown),
    );
  }
}

/// 작성자 아바타 + `이름 · 날짜 · 회의록` (읽기 전용).
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.author});

  final NoteAuthor author;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.blue500,
            shape: BoxShape.circle,
          ),
          child: Text(
            author.initial,
            style: AppFont.labelXs.copyWith(
              fontSize: 9,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Text(
            '${author.name}  ·  ${author.date}  ·  회의록',
            style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
          ),
        ),
      ],
    );
  }
}

/// 빨간 accent bar + 라벨 + 멀티라인 마크다운 입력창으로 이뤄진 편집 섹션.
class _EditSection extends StatelessWidget {
  const _EditSection({
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.hintText,
  });

  final String title;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.red400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Text(
              title,
              style: AppFont.labelXs.copyWith(
                fontWeight: AppFont.semiBold,
                color: AppColors.darkOnSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.s10),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: null,
            cursorColor: AppColors.red400,
            style: AppFont.subtextM.copyWith(
              fontSize: 15,
              height: 1.45,
              color: AppColors.darkOnSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: AppFont.subtextM.copyWith(
                fontSize: 15,
                color: AppColors.neutral500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 하단 서식 툴바. Figma `Toolbar`(neutral 배경 + 상단 보더) 스타일.
///
/// 각 버튼은 포커스된 섹션 입력창에 마크다운을 삽입한다.
class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({required this.onAction});

  final void Function(MarkdownAction) onAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neutral800,
      child: SafeArea(
        top: false,
        child: Container(
          height: 54,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.neutral700, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolbarButton(
                label: 'H',
                onTap: () => onAction(MarkdownAction.heading),
              ),
              _ToolbarButton(
                label: 'B',
                onTap: () => onAction(MarkdownAction.bold),
              ),
              _ToolbarButton(
                icon: Icons.format_list_bulleted,
                onTap: () => onAction(MarkdownAction.bullet),
              ),
              _ToolbarButton(
                icon: Icons.check_box_outlined,
                onTap: () => onAction(MarkdownAction.checkbox),
              ),
              _ToolbarButton(
                label: '@',
                onTap: () => onAction(MarkdownAction.mention),
              ),
              _ToolbarButton(
                icon: Icons.attach_file,
                // ponytail: 첨부는 마크다운 텍스트 노트 범위 밖. 안내만 노출.
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('파일 첨부는 준비 중이에요.')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({this.label, this.icon, required this.onTap})
    : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r8),
      child: SizedBox(
        width: 40,
        height: 36,
        child: Center(
          child: icon != null
              ? Icon(icon, size: 18, color: AppColors.neutral300)
              : Text(
                  label!,
                  style: AppFont.labelS.copyWith(
                    fontWeight: AppFont.semiBold,
                    color: AppColors.neutral300,
                  ),
                ),
        ),
      ),
    );
  }
}

/// 툴바가 삽입할 수 있는 마크다운 서식 종류.
enum MarkdownAction { bold, heading, bullet, checkbox, mention }

/// 포커스된 텍스트에 마크다운 서식을 적용한 결과(새 텍스트 + 커서 위치)를 돌려준다.
///
/// 위젯 없이 테스트할 수 있는 순수 함수다.
({String text, TextSelection selection}) applyMarkdown(
  String text,
  TextSelection selection,
  MarkdownAction action,
) {
  // 유효하지 않은 선택(-1)은 문서 끝 커서로 취급한다.
  final start = selection.start < 0 ? text.length : selection.start;
  final end = selection.end < 0 ? start : selection.end;

  switch (action) {
    case MarkdownAction.bold:
      if (start == end) {
        final next = '${text.substring(0, start)}****${text.substring(start)}';
        return (
          text: next,
          selection: TextSelection.collapsed(offset: start + 2),
        );
      }
      final selected = text.substring(start, end);
      final next =
          '${text.substring(0, start)}**$selected**${text.substring(end)}';
      return (text: next, selection: TextSelection.collapsed(offset: end + 4));
    case MarkdownAction.mention:
      final next = '${text.substring(0, start)}@${text.substring(end)}';
      return (
        text: next,
        selection: TextSelection.collapsed(offset: start + 1),
      );
    case MarkdownAction.heading:
      return _prefixLine(text, start, '# ');
    case MarkdownAction.bullet:
      return _prefixLine(text, start, '- ');
    case MarkdownAction.checkbox:
      return _prefixLine(text, start, '- [ ] ');
  }
}

/// [offset]이 놓인 줄의 맨 앞에 [prefix]를 삽입한다.
({String text, TextSelection selection}) _prefixLine(
  String text,
  int offset,
  String prefix,
) {
  final searchFrom = offset - 1;
  final newlineIndex = searchFrom < 0 ? -1 : text.lastIndexOf('\n', searchFrom);
  final lineStart = newlineIndex + 1;
  final next =
      '${text.substring(0, lineStart)}$prefix${text.substring(lineStart)}';
  return (
    text: next,
    selection: TextSelection.collapsed(offset: offset + prefix.length),
  );
}

final _checkedItem = RegExp(r'^-\s*\[[xX]\]\s?(.*)$');
final _uncheckedItem = RegExp(r'^-\s*\[\s?\]\s?(.*)$');

/// 액션 아이템 마크다운을 구조화된 [NoteActionItem] 목록으로 파싱한다.
///
/// `- [x] ...` → 완료, `- [ ] ...` → 미완료, 그 밖의 비어있지 않은 줄도 미완료 항목으로 취급한다.
List<NoteActionItem> parseActionItems(String markdown) {
  final items = <NoteActionItem>[];
  for (final raw in markdown.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    final checked = _checkedItem.firstMatch(line);
    if (checked != null) {
      items.add(NoteActionItem(label: checked.group(1)!.trim(), done: true));
      continue;
    }
    final unchecked = _uncheckedItem.firstMatch(line);
    if (unchecked != null) {
      items.add(NoteActionItem(label: unchecked.group(1)!.trim()));
      continue;
    }
    // 체크박스 문법이 아닌 줄은 앞의 불릿(-)만 떼고 미완료 항목으로.
    items.add(
      NoteActionItem(label: line.replaceFirst(RegExp(r'^-\s*'), '').trim()),
    );
  }
  return items;
}

String _actionItemsToMarkdown(List<NoteActionItem> items) =>
    items.map((i) => '- [${i.done ? 'x' : ' '}] ${i.label}').join('\n');

List<String> _splitLines(String text) => [
  for (final line in text.split('\n'))
    if (line.trim().isNotEmpty) line,
];
